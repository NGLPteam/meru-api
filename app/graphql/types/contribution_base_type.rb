# frozen_string_literal: true

module Types
  # @see Contribution
  # @see Types::ContributionType
  # @see Types::TemplateContributionType
  # @see Types::CollectionContributionType
  # @see Types::ItemContributionType
  module ContributionBaseType
    include Types::BaseInterface

    description <<~TEXT
    An interface representing a contribution from a certain contributor.

    It leaves the `contributor` field's implementation up to later
    implementations, as we have different needs elsewhere in the API.

    See `Contribution` and `TemplateContribution`.
    TEXT

    field :contributor_kind, Types::ContributorKindType, null: false

    field :metadata, Types::ContributionMetadataType, null: false

    field :contribution_role, Types::ControlledVocabularyItemType, null: false, description: "The actual role"

    field :inner_position, Int, null: true do
      description <<~TEXT
      An optional sorting discriminator to decide which contribution ranks higher.

      Applies _after_ contribution role ranking.
      TEXT
    end

    field :outer_position, Int, null: true do
      description <<~TEXT
      An optional sorting discriminator to decide which contribution ranks higher.

      Applies _before_ contribution role ranking, superseding everything else.
      TEXT
    end

    field :role, String, null: true, description: "An arbitrary text value describing the role the contributor had",
      deprecation_reason: "Use `roleLabel` instead."

    field :role_label, String, null: true do
      description "An arbitrary text value describing the role the contributor had"
    end

    field :display_name, String, null: false do
      description "A potentially-overridden display name value for all contributor types"
    end

    field :title, String, null: true do
      description "A potentially-overridden value from person contributors"
    end

    field :affiliation, String, null: true do
      description "A potentially-overridden value from person contributors"
    end

    field :location, String, null: true do
      description "A potentially-overridden value from organization contributors"
    end

    load_association! :role, as: :contribution_role

    def role
      role_label
    end

    # @return [String]
    def role_label
      contribution_role.then(&:label)
    end
  end
end
