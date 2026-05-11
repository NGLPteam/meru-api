# frozen_string_literal: true

module Types
  # @see ControlledVocabularyItem
  class ControlledVocabularyItemType < Types::BaseModel
    description <<~TEXT
    An individual term within a `ControlledVocabulary`.
    TEXT

    field :identifier, String, null: false do
      description <<~TEXT
      The unique, machine-readable identifier within the `ControlledVocabulary`.
      TEXT
    end

    field :label, String, null: false do
      description <<~TEXT
      The unique label for the Controlled Vocabulary.
      TEXT
    end

    field :description, String, null: true do
      description <<~TEXT
      An optional, internal description for this specific term.
      TEXT
    end

    field :priority, Integer, null: true do
      description <<~TEXT
      An optional priority for certain programmatic sorting tasks within Meru API.
      TEXT
    end

    field :tags, [String, { null: false }], null: false do
      description <<~TEXT
      Optional tags used for certain programmatic tasks within Meru API.
      TEXT
    end

    field :url, String, null: true do
      description <<~TEXT
      An optional URL that should be linked to if present, using the `label` as link text,
      when displaying.
      TEXT
    end

    field :unselectable, Boolean, null: false do
      description <<~TEXT
      Whether or not this should just be used as a grouping label and not be selectable. Implies children.
      TEXT
    end

    field :children, [self, { null: false }], null: false do
      description <<~TEXT
      Any children for this vocab item. Starting from a depth of 0 at the top level, items cannot nest any deeper than 2.
      TEXT
    end
  end
end
