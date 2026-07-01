# frozen_string_literal: true

module Templates
  module Config
    module Utility
      # Shale does not natively support the concept of a polymorphic XML collection.
      #
      # However, it provides us a pretty comprehensive subsystem we can hook into in
      # order to handle this.
      #
      # @abstract
      class PolymorphicTemplateMapper < Shale::Mapper
        extend Dry::Core::ClassAttributes

        include Dry::Core::Constants
        include Dry::Core::Memoizable

        defines :template_mapping, type: Templates::Config::Utility::Types::PolymorphicTemplateMapping

        template_mapping EMPTY_HASH

        attribute :errors, Shale::Type::Value, collection: true
        attribute :templates, Shale::Type::Value, collection: true

        xml do
          root "templates"

          map_content to: :templates, using: { from: :templates_from_xml, to: :templates_to_xml }
        end

        delegate :template_klass_for, to: :class

        # @param [Templates::Config::Utility::PolymorphicTemplateSet] model
        # @param [Shale::Adapter::Ox::Node] element
        # @return [void]
        def templates_from_xml(model, element)
          process_templates(element) => { templates:, errors: }

          model.templates = templates
          model.errors = errors
        end

        # @param [Templates::Config::Utility::PolymorphicTemplateSet] model
        # @return [void]
        def templates_to_xml(model, element, doc)
          model.each do |template|
            element << template.to_ox_element
          end
        end

        private

        # @param [Shale::Adapter::Ox::Node] element
        def process_templates(element)
          hsh = { templates: [], errors: [], }

          element.children.each_with_index.each_with_object(hsh) do |(child, index), h|
            h[:templates] << process_template(child, index)
          rescue Templates::Config::Utility::UnacceptableTemplateError => e
            h[:errors] << e
          end
        end

        def process_template(element, index)
          template_klass = template_klass_for(element.name, index:)

          template = template_klass.from_xml(Ox.dump(element.instance_variable_get(:@node)))

          template.position = index + 1

          return template
        end

        class << self
          # @api private
          # @param [Class<Templates::Config::Utility::AbstractTemplate>, String, Symbol] input
          # @return [void]
          def accept_template!(input)
            template_klass = derive_template_klass_from(input)

            root = validate_template_klass! template_klass

            merged = template_mapping.merge(root => template_klass).freeze

            template_mapping merged

            return nil
          end

          # @param [Class<Templates::Config::Utility::AbstractTemplate>, String, Symbol] input
          def accepts_template?(input)
            template_klass = derive_template_klass_from(input)

            root = template_klass.xml_mapping

            accepts_template_root?(root.to_s)
          rescue NoMatchingTemplateError
            false
          end

          # @param [#to_s] root
          def accepts_template_root?(root)
            template_mapping.key? root.to_s
          end

          # @return [Templates::Config::Utility::PolymorphicTemplateMapper]
          def build_default
            templates = layout_record.default_templates.map do |template_kind|
              template_klass = constantize_template_name(template_kind)

              template_klass.new
            end

            attrs = { templates: }.stringify_keys

            from_hash(attrs)
          end

          # Configure the layout _and_ its associated templates.
          #
          # @see .accept_template!
          # @param [Layouts::Types::Kind] raw_layout
          # @return [void]
          def configures_templates_for_layout!(raw_layout)
            configures_layout! raw_layout

            layout_record.template_kinds.sort.each do |template_kind|
              accept_template! template_kind
            end

            model ::Templates::Config::Utility::PolymorphicTemplateSet

            xml_mapping.root "templates"
          end

          def inherited(klass)
            klass.include ::Templates::Config::ConfiguresLayout

            super
          end

          # @raise [Templates::Config::Utility::UnacceptableTemplateError]
          # @return [Class<Templates::Config::Utility::AbstractTemplate>]
          def template_klass_for(root, index: 0)
            unless accepts_template_root?(root)
              raise Templates::Config::Utility::UnacceptableTemplateError.new(root, layout_kind:, index:)
            end

            template_mapping.fetch(root.to_s)
          end

          private

          # @param [#to_s] input
          # @raise [Templates::Config::Utility::NoMatchingTemplateError]
          # @return [Class<Templates::Config::Utility::AbstractTemplate>]
          def constantize_template_name(input)
            base = input.to_s.underscore

            klass_path = "templates/config/template/#{base}"

            klass_string = "::#{klass_path.classify}"

            derive_template_klass_from klass_string.safe_constantize
          rescue NameError
            raise NoMatchingTemplateError, "Could not find template config for #{input.inspect}"
          end

          # @param [Class<Templates::Config::Utility::AbstractTemplate>, String] input
          # @raise [Templates::Config::Utility::NoMatchingTemplateError]
          # @return [Class<Templates::Config::Utility::AbstractTemplate>]
          def derive_template_klass_from(input)
            case input
            when Templates::Config::Utility::Types::TemplateConfigKlass
              input
            when String, Symbol
              constantize_template_name(input)
            else
              # simplecov:disable
              raise NoMatchingTemplateError, "Invalid template class input: #{input.inspect}"
              # simplecov:enable
            end
          end

          # @param [Class<Templates::Config::Utility::AbstractTemplate>] template_klass
          # @raise [RuntimeError] since this evaluates in a DSL, it's only used
          #   to detect obvious configuration issues that won't occur during normal
          #   execution, but instead stuff that should be fixed before releasing any
          #   changes.
          # @return [String] the root for the template to use as its key.
          def validate_template_klass!(template_klass)
            # simplecov:disable
            root = template_klass.xml_root

            raise "No root specified" if root.blank?

            raise "Duplicate XML Root: #{root} already defined for #{template_mapping[root].name}" if accepts_template?(root)

            return root
            # simplecov:enable
          end
        end
      end
    end
  end
end
