# frozen_string_literal: true

module Metadata
  module Shared
    module Attrs
      # @api private
      class CollectionAccessor < Module
        include Dry::Initializer[undefined: false].define -> do
          param :attribute, ::Metadata::Types.Instance(::Lutaml::Model::Attribute)
          param :singular_name, ::Metadata::Types::Symbol
        end

        delegate :name, to: :attribute, prefix: :attr

        # @return [Symbol]
        attr_reader :derivation_method

        def initialize(...)
          super

          @derivation_method = :"derive_#{singular_name}"

          generate_derivation_method!
        end

        def included(base)
          # simplecov:disable
          super if defined?(super)
          # simplecov:enable

          base.attribute singular_name, method: derivation_method
        end

        private

        # @return [void]
        def generate_derivation_method!
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{derivation_method}
            Array(#{attr_name}).first
          end
          RUBY
        end
      end
    end
  end
end
