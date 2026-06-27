# frozen_string_literal: true

module Support
  module ClassyList
    module DSL
      extend ActiveSupport::Concern

      module ClassMethods
        # @param [Symbol] name The name of the message map to define.
        # @param [Dry::Types::Type] item_type The base name for the DSL methods to define.
        # @return [void]
        def has_classy_list!(name, item_type, list_type: Types::Array.of(item_type), **options)
          config = Support::ClassyList::Configuration.new(name, **options, item_type:, list_type:)

          extend config.klass_implementation
        end

        # @return [void]
        def has_simple_message_map!(name, item_type, **options)
          has_classy_list!(name, item_type, **options, realize_mode: :hash)
        end

        # @return [void]
        def has_simple_message_list!(name, item_type, **options)
          has_classy_list!(name, item_type, **options, realize_mode: :array)
        end

        # @return [void]
        def has_simple_symbol_list!(name, **options)
          has_classy_list!(name, Types::Symbol, **options, realize_mode: :none)
        end
      end
    end
  end
end
