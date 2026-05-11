# frozen_string_literal: true

module Types
  # @see Roles::ContributorPermissionGrid
  class ContributorPermissionGridType < Types::BaseObject
    implements Types::PermissionGridType
    implements Types::CRUDPermissionGridType

    description <<~TEXT
    A grid of permissions for managing contributors in Meru.

    Contributors are a "global" record, in that they exist
    outside of the entity hierarchy.

    `update` permissions for contributors can also be granted
    by assigning that contributor to a user.
    TEXT

    field :claim, Boolean, null: false do
      description <<~TEXT
      Whether or not a user with this permission can claim a contributor.

      This is distinct from creating or updating in that it only
      applies to unclaimed contributors contributes the following auth results:

      - `Contributor.canClaim`
      - `User.canClaimContributor`

      See `Mutations.contributorClaim` for more details.
      TEXT
    end

    field :merge, Boolean, null: false do
      description <<~TEXT
      Whether or not a user with this permission can merge contributor records together.

      This is distinct from `update` in that it only applies to the `contributorMerge` permission,
      and feeds into the `canMergeSource` and `canMergeTarget` permissions on `Contributor`.
      TEXT
    end
  end
end
