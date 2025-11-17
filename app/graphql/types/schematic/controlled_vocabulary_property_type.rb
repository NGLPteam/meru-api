# frozen_string_literal: true

module Types
  module Schematic
    class ControlledVocabularyPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::Schematic::HasControlledVocabularyType

      field :controlled_vocabulary_item, "Types::ControlledVocabularyItemType", null: true, method: :value
    end
  end
end
