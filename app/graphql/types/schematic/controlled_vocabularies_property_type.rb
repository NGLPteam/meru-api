# frozen_string_literal: true

module Types
  module Schematic
    class ControlledVocabulariesPropertyType < Types::AbstractObjectType
      implements ::Types::Schematic::SchemaPropertyType
      implements ::Types::Schematic::ScalarPropertyType
      implements ::Types::Schematic::HasControlledVocabularyType

      field :controlled_vocabulary_items, ["Types::ControlledVocabularyItemType", { null: false }], null: false, method: :value
    end
  end
end
