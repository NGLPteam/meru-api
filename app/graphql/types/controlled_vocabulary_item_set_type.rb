# frozen_string_literal: true

module Types
  class ControlledVocabularyItemSetType < Types::BaseScalar
    description <<~TEXT
    An array-like representation of the item sets, presented this way
    to avoid having to query recursively.

    See the types at `/types/controlled_vocabulary_item_set.d.ts`.
    TEXT

    class << self
      def coerce_input(input_value, _context)
        # simplecov:disable
        input_value
        # simplecov:enable
      end

      # @return [Array<Hash>]
      def coerce_result(ruby_value, _context)
        Array(ruby_value).as_json
      end
    end
  end
end
