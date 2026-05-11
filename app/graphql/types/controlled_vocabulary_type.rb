# frozen_string_literal: true

module Types
  # @see ControlledVocabulary
  class ControlledVocabularyType < Types::BaseModel
    description <<~TEXT
    A set of terms that can be selected in schemas.

    See also `ControlledVocabularyItem` and `ControlledVocabularySource`.
    TEXT

    field :namespace, String, null: false do
      description <<~TEXT
      The namespace the controlled vocabulary lives in.
      TEXT
    end

    field :identifier, String, null: false do
      description <<~TEXT
      A unique identifier for the controlled vocabulary (within the namespace).
      TEXT
    end

    field :version, String, null: false do
      description <<~TEXT
      A unique version for the controlled vocabulary (within the namespace/identifier).
      TEXT
    end

    field :provides, String, null: false do
      description <<~TEXT
      The schema value that is provided by the CV.

      See `ControlledVocabularySource` for more details.
      TEXT
    end

    field :name, String, null: false do
      description <<~TEXT
      The human-readable name of the controlled vocabulary.
      TEXT
    end

    field :description, String, null: true do
      description <<~TEXT
      An optional internal description of the purpose/values contained within.
      TEXT
    end

    field :item_set, ::Types::ControlledVocabularyItemSetType, null: false do
      description <<~TEXT
      The items to render for this specific controlled vocabulary.

      This will be returned as a JSON array.

      See the type definitions at `/types/controlled_vocabulary_item_set.d.ts`.
      TEXT
    end

    field :items, [::Types::ControlledVocabularyItemType, { null: false }], null: false do
      description <<~TEXT
      The raw root item records.
      TEXT
    end

    load_association! :controlled_vocabulary_root_items, as: :items
  end
end
