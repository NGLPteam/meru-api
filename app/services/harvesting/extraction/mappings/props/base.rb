# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      module Props
        # @abstract
        class Base < Harvesting::Extraction::Mappings::Abstract
          defines :property_attr, type: ::Harvesting::Extraction::Types::Symbol.optional
          defines :property_root, type: ::Harvesting::Extraction::Types::String.optional
          defines :property_type, type: ::Harvesting::Extraction::Types::SchemaPropertyType

          property_type "unknown"

          property_attr nil

          property_root nil

          attribute :path, :string

          xml do
            map_attribute "path", to: :path
          end

          def environment_options
            super.merge(
              property_type: self.class.property_type
            )
          end

          # @abstract
          # @param [Harvesting::Extraction::RenderContext] render_context
          # @return [Dry::Monads::Result]
          def render_value_for(render_context)
            safely_rendered_subproperties_for render_context
          end

          private

          # @abstract
          # @param [{ Symbol => Object}] subproperties
          # @return [Dry::Monads::Success(Object)]
          # @return [Dry::Monads::Failure]
          def build_property_value_with(**subproperties)
            Dry::Monads.Success subproperties
          end

          # @param [Harvesting::Extraction::RenderContext] render_context
          # @return [Dry::Monads::Success{ Symbol => Object }]
          # @return [Dry::Monads::Failure(:properties_invalid, <Harvesting::Extraction::Properties::Warning>)]
          # @return [Dry::Monads::Failure(:properties_failed, <Harvesting::Extraction::Properties::Error>)]
          def safely_rendered_subproperties_for(render_context)
            attrs = rendered_attributes_for(render_context)

            property_errors = []

            subproperties = attrs.each_with_object({}) do |(attr, result), new|
              subpath = attr.to_s

              Dry::Matcher::ResultMatcher.(result) do |m|
                m.success do |value|
                  new[attr.to_sym] = value
                end

                m.failure :cannot_coerce do |_, message|
                  property_errors << Harvesting::Extraction::Properties::Error.new(path:, subpath:, message:, coercion_error: true)
                end

                m.failure :cannot_render do |_, render_result|
                  render_result.errors.each do |base_error|
                    error = Harvesting::Extraction::Properties::Error.from(path, subpath, base_error)

                    property_errors << error
                  end
                end

                m.failure :render_invalid do |_, validator|
                  warnings = validator.errors.map do |error|
                    Harvesting::Extraction::Properties::Warning.from_validation(path:, subpath:, error:)
                  end

                  return Dry::Monads::Failure[:properties_invalid, warnings]
                end

                m.failure do
                  # simplecov:disable
                  property_errors << Harvesting::Extraction::Properties::Error.new(path:, subpath:, message: "Something went wrong")
                  # simplecov:enable
                end
              end
            end

            if property_errors.any?
              Dry::Monads::Failure[:properties_failed, property_errors]
            else
              build_property_value_with(**subproperties)
            end
          end

          class << self
            # @api private
            # @return [void]
            def derive_property_type!
              derived_type = ::Harvesting::Extraction::Types::SchemaPropertyType[name.demodulize.underscore]

              property_type derived_type

              unless property_type == "unknown"
                property_attr :"#{property_type}_props"

                property_root property_type.to_s.dasherize
              else
                property_attr nil

                property_root nil
              end
            end

            def inherited(subclass)
              super

              subclass.derive_property_type!
            end
          end
        end
      end
    end
  end
end
