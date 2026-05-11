# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::ContributorClaim
  class ContributorClaim < Mutations::BaseMutation
    description <<~TEXT
    A mutation to claim a contributor profile as the current user.

    This is intended to be used by depositors who have already had contributions harvested
    and may have an existing `Contributor` record in the system.

    It relies upon the `canClaim` permission on the given `Contributor`,
    and by proxy, whether or not `Contributor.claimed` is `false`.
    TEXT

    field :contributor, Types::ContributorType, null: true do
      description <<~TEXT
      The contributor that was claimed by the current user, if successful.
      TEXT
    end

    field :contributor_user_link, Types::ContributorUserLinkType, null: true do
      description <<~TEXT
      The link between the claimed contributor and the current user, if the claim was successful.
      TEXT
    end

    field :user, Types::UserType, null: true do
      description <<~TEXT
      The current user, if the claim was successful.
      TEXT
    end

    argument :contributor_id, ID, loads: Types::ContributorType, required: true do
      description <<~TEXT
      The ID of the contributor to claim. This should be a contributor that has already been harvested for the current user.
      TEXT
    end

    performs_operation! "mutations.operations.contributor_claim"
  end
end
