# frozen_string_literal: true

module Types
  # @see Contribution
  # @see Types::ContributionBaseType
  # @see Types::CollectionContributionType
  # @see Types::ItemContributionType
  module ContributionType
    include Types::BaseInterface

    description <<~TEXT
    An interface representing a contribution from a certain contributor.
    TEXT

    implements Types::ContributionBaseType

    field :contributor, "Types::ContributorType", null: false do
      description <<~TEXT
      The contributor, loaded via union for the most control.
      TEXT
    end
  end
end
