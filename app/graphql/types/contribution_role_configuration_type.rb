# frozen_string_literal: true

module Types
  # @see ContributionRoleConfiguration
  class ContributionRoleConfigurationType < Types::BaseModel
    description <<~TEXT
    Configuration for the controlled vocabulary used for contribution roles on a given `source`.
    TEXT

    field :controlled_vocabulary, Types::ControlledVocabularyType, null: false do
      description <<~TEXT
      The set of items to use for contribution roles for this source.
      TEXT
    end

    field :default_item, Types::ControlledVocabularyItemType, null: false do
      description <<~TEXT
      The default item to use when a contribution is created but no role is provided.
      This is necessary as a fallback for harvesting and other use cases.
      TEXT
    end

    field :other_item, Types::ControlledVocabularyItemType, null: true do
      description <<~TEXT
      The "other" item in the set, if available (logic to be implemented later).
      TEXT
    end

    load_association! :controlled_vocabulary
    load_association! :default_item
    load_association! :other_item
  end
end
