# frozen_string_literal: true

module Types
  # @see ContributorUserLink
  class ContributorUserLinkType < Types::BaseModel
    description <<~TEXT
    A link between a `Contributor` and a `User`, indicating that the user
    is represented within Meru as that record.
    TEXT

    field :contributor, "::Types::ContributorType", null: false do
      description <<~TEXT
      The contributor associated with this link.
      TEXT
    end

    field :user, "::Types::UserType", null: true do
      description <<~TEXT
      The user associated with this link.

      If the current viewer cannot see the user record, this will be null.
      TEXT
    end

    field :linkage, Types::ContributorUserLinkageType, null: false do
      description <<~TEXT
      The type of link between the contributor and user.
      TEXT
    end

    load_association! :contributor
    load_association! :user
  end
end
