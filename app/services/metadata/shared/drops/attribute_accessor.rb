# frozen_string_literal: true

module Metadata
  module Shared
    module Drops
      # @api private
      class AttributeAccessor < Module
        include Dry::Initializer[undefined: false].define -> do
          param :attribute, ::Metadata::Types.Instance(::Lutaml::Model::Attribute)
        end

        delegate :name, to: :attribute, prefix: :attr

        def initialize(...)
          super

          generate_accessor!
        end

        def included(base)
          # simplecov:disable
          super if defined?(super)
          # simplecov:enable

          base.memoize attr_name

          base.after_initialize attr_name

          base.include(Metadata::Shared::Drops::StringCoercion) if has_string_content?
        end

        private

        # @return [void]
        def generate_accessor!
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{attr_name}
            build_child_drop_for #{attr_name.inspect}
          end
          RUBY
        end

        def has_string_content?
          attr_name == :content && attribute.type.present? && attribute.type <= ::Lutaml::Model::Type::String
        end
      end
    end
  end
end
