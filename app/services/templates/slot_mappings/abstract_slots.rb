# frozen_string_literal: true

module Templates
  module SlotMappings
    # @abstract
    class AbstractSlots
      extend Dry::Core::ClassAttributes

      include Enumerable
      include Support::EnhancedStoreModel

      SlotKlass = ::Templates::Types.Interface(:to_type)
      SlotList = ::Templates::Types::Array.of(Templates::Types::Coercible::Symbol)

      defines :inline_slots, :block_slots, :all_slots, type: SlotList
      defines :inline_slot_klass, :block_slot_klass, type: SlotKlass.optional

      attribute :template_kind, :string

      block_slots [].freeze
      inline_slots [].freeze
      all_slots [].freeze

      def each
        # simplecov:disable
        return enum_for(__method__) unless block_given?
        # simplecov:enable

        self.class.all_slots.each do |slot_name|
          yield [slot_name, __send__(slot_name)]
        end
      end

      # @return [{ String => String, nil }]
      def export
        each.to_h do |key, value|
          [key.to_s, value&.export_value]
        end
      end

      class << self
        def block!(name, **options)
          all_slots [*all_slots, name].freeze
          block_slots [*block_slots, name].freeze

          attribute name, block_slot_klass.to_type, **options
        end

        def inline!(name, **options)
          all_slots [*all_slots, name].freeze
          inline_slots [*inline_slots, name].freeze

          attribute name, inline_slot_klass.to_type, **options
        end
      end
    end
  end
end
