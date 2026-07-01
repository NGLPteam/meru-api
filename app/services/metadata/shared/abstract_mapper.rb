# frozen_string_literal: true

module Metadata
  module Shared
    # @abstract
    class AbstractMapper < Lutaml::Model::Serializable
      extend Dry::Core::ClassAttributes

      include Dry::Core::Constants

      class << self
        def attribute(name, type = nil, expose_single: false, **options)
          model_attribute = type.nil? ? super(name, options) : super(name, type, options)

          register_liquid_drop_class

          accessor = Metadata::Shared::Drops::AttributeAccessor.new(model_attribute)

          drop_class.include accessor

          if options[:collection] && expose_single
            singular_name = expose_single.kind_of?(Symbol) ? expose_single : model_attribute.name.to_s.singularize.to_sym

            singularizer = Metadata::Shared::Attrs::CollectionAccessor.new(model_attribute, singular_name)

            include singularizer
          end

          return model_attribute
        end

        # @param [Symbol] attr_name
        # @return [void]
        def stringifies_drop_with!(attr_name)
          register_liquid_drop_class

          drop_class.include(Metadata::Shared::Drops::StringCoercion)

          drop_class.string_coercion_attribute attr_name
        end

        # @api private
        # @note We override this to use our custom base drop.
        # @return [void]
        def register_liquid_drop_class
          validate_liquid!

          # simplecov:disable
          return if drop_class.present?
          # simplecov:enable

          const_set(drop_class_name, Class.new(::Metadata::Shared::AbstractDrop))
        end
      end
    end
  end
end
