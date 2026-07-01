# frozen_string_literal: true

module Templates
  module Config
    # A concern that helps rebuild and reload certain template slots / properties so they can
    # be organized by template kind in separate files, but queried all at once.
    #
    # @note Must be included on a FrozenRecord model.
    module SourcedByTemplateKind
      extend ActiveSupport::Concern

      TEMPLATE_KINDS = ApplicationRecord.pg_enum_values(:template_kind).sort.freeze

      TEMPLATING_ROOT = Rails.root.join("lib", "templating")

      included do
        include Dry::Core::Equalizer.new(:template_kind, :name)
        include Dry::Core::Memoizable

        defines :multiline_attrs, type: ::Support::GlobalTypes::Array.of(::Support::GlobalTypes::String)
        defines :sourced_subdirectory, type: Dry::Types["string"].enum("properties", "slots")
        defines :sourced_root, type: ::Support::GlobalTypes::Path

        multiline_attrs Dry::Core::Constants::EMPTY_ARRAY
        sourced_subdirectory derive_sourced_subdirectory
        sourced_root TEMPLATING_ROOT.join(sourced_subdirectory)

        calculates_id_from! :template_kind, :name

        self.primary_key = :id

        add_index :id, unique: true

        add_index :name

        add_index :template_kind

        scope :for_template, ->(kind) { where(template_kind: kind.to_s) }

        memoize :template
      end

      # @!attribute [r] template
      # @return [Template]
      def template
        ::Template.find template_kind
      end

      module ClassMethods
        # @param [<String>] attr_names
        # @return [void]
        def multiline!(*attr_names)
          attr_names.flatten!

          new_attrs = multiline_attrs | attr_names.flatten.map(&:to_s)

          multiline_attrs new_attrs.freeze
        end

        # @return [void]
        def recompile_from_source!
          new_records = recompile_records

          File.write(file_path, YAML.dump(new_records))

          load_records(force: true)
        end

        private

        def recompile_records
          TEMPLATE_KINDS.flat_map do |template_kind|
            recompile_records_for template_kind
          end
        end

        def recompile_records_for(template_kind)
          basename = "#{template_kind}.yml"

          path = sourced_root.join(basename)

          # simplecov:disable
          return EMPTY_ARRAY unless path.exist?
          # simplecov:enable

          raw_records = YAML.load_file(path)

          raw_records.map do |name, attributes|
            recompile_record(template_kind, name, attributes)
          end.then { sort_attributes_in _1 }
        end

        def recompile_record(template_kind, name, attributes)
          base_attrs = attributes.to_h do |k, v|
            if k.in?(multiline_attrs)
              [k, recompile_multiline(v)]
            else
              [k, v]
            end
          end.compact.with_indifferent_access

          base_attrs.merge(name:, template_kind:).deep_stringify_keys
        end

        # @param [#to_s] value
        # @return [String, nil]
        def recompile_multiline(value)
          # simplecov:disable
          return if value.blank? || !value.kind_of?(String)
          # simplecov:enable

          value.strip
        end

        # @api private
        # @return [String]
        def derive_sourced_subdirectory
          # simplecov:disable
          case name
          in "TemplateProperty" then "properties"
          in "TemplateSlot" then "slots"
          end
          # simplecov:enable
        end
      end
    end
  end
end
