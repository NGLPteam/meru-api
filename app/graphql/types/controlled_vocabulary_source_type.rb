# frozen_string_literal: true

module Types
  # @see ControlledVocabularySource
  class ControlledVocabularySourceType < Types::BaseModel
    description <<~TEXT
    A system-wide configuration that determines which `ControlledVocabulary` satisfies
    a desired `provides` value in schemas.
    TEXT

    field :provides, String, null: false do
      description <<~TEXT
      This conforms to the `wants` attribute in CV schema properties.
      TEXT
    end

    field :controlled_vocabulary, ::Types::ControlledVocabularyType, null: true do
      description <<~TEXT
      The controlled vocabulary that provides terms, if selected / available.

      It can be blank when it needs to be populated.
      TEXT
    end
  end
end
