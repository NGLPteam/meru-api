# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::ContributorUserLinkUpsert
  class ContributorUserLinkUpsert < Mutations::BaseMutation
    description <<~TEXT
    Create or update a link between a `Contributor` and a `User`.

    It relies upon the `canLinkUser` permission on the given `Contributor`.
    TEXT

    field :contributor, Types::ContributorType, null: true do
      description <<~TEXT
      The newly-linked contributor, if successful.
      TEXT
    end

    field :contributor_user_link, Types::ContributorUserLinkType, null: true do
      description <<~TEXT
      The newly-created or updated link, if successful.
      TEXT
    end

    field :user, Types::UserType, null: true do
      description <<~TEXT
      The user linked to the contributor, if successful.
      TEXT
    end

    argument :contributor_id, ID, loads: Types::ContributorType, required: true do
      description <<~TEXT
      The contributor to update.
      TEXT
    end

    argument :user_id, ID, loads: Types::UserType, required: true do
      description <<~TEXT
      The user to link to the contributor.
      TEXT
    end

    argument :linkage, Types::ContributorUserLinkageType, required: true do
      description <<~TEXT
      The type of link to create or update between the contributor and user.

      Setting `PRIMARY` will override any other primary set for the associated user.
      TEXT
    end

    performs_operation! "mutations.operations.contributor_user_link_upsert"
  end
end
