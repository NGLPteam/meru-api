# frozen_string_literal: true

module Schemas
  module Instances
    # @see Entities::CalculateComposedTexts
    class ExtractComposedText
      include MeruAPI::Deps[
        calculate_composed_texts: "entities.calculate_composed_texts"
      ]

      def call(entity)
        calculate_composed_texts.(entity:)
      end
    end
  end
end
