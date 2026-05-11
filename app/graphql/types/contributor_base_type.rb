# frozen_string_literal: true

module Types
  module ContributorBaseType
    include Types::BaseInterface

    description <<~TEXT
    An interface for an abstract contributor who has made a contribution.

    See `kind` for what type it is.

    This type differentiates from `Contributor` in that it lacks the ability to grab contributions,
    in order to prevent inordinately long nesting in GQL fetches in certain situations.
    TEXT

    implements Types::HasHarvestModificationStatusType
    implements ::Support::GQL::CommonPermissionsType
    implements ::Support::GQL::SluggableType

    field :kind, Types::ContributorKindType, null: false

    field :identifier, String, null: false

    field :email, String, null: true

    field :prefix, String, null: true

    field :suffix, String, null: true

    field :bio, String, null: true

    field :url, String, null: true

    field :orcid, String, null: true do
      description <<~TEXT
      An optional, unique [**O**pen **R**esearcher and **C**ontributor **ID**](https://orcid.org) associated with this contributor.
      TEXT
    end

    field :name, String, null: false, method: :safe_name do
      description <<~TEXT
      A display name, independent of the type of contributor.
      TEXT
    end

    image_attachment_field :image,
      description: "An optional image associated with the contributor."

    field :links, [Types::ContributorLinkType, { null: false }], null: false

    field :contribution_count, Integer, null: false do
      description <<~TEXT
      The total number of contributions (item + collection) from this contributor.
      TEXT
    end

    field :collection_contribution_count, Integer, null: false do
      description <<~TEXT
      The total number of collection contributions from this contributor.
      TEXT
    end

    field :item_contribution_count, Integer, null: false do
      description <<~TEXT
      The total number of item contributions from this contributor.
      TEXT
    end

    field :given_name, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `PERSON`.
      TEXT
    end

    field :family_name, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `PERSON`.
      TEXT
    end

    field :title, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `PERSON`.
      TEXT
    end

    field :affiliation, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `PERSON`.
      TEXT
    end

    field :legal_name, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `ORGANIZATION`.
      TEXT
    end

    field :location, String, null: true do
      description <<~TEXT
      Only applicable when `kind` = `ORGANIZATION`.
      TEXT
    end

    field :user_link, Types::ContributorUserLinkType, null: true do
      description <<~TEXT
      The link between this contributor and a user, if any exists.
      TEXT
    end

    field :claimed, Boolean, null: false, method: :claimed? do
      description <<~TEXT
      Whether this contributor has been claimed by a user.
      TEXT
    end

    field :merge_busy, Boolean, null: false, method: :merge_busy? do
      description <<~TEXT
      Whether this contributor is currently involved in an active merge as either a source or target.
      TEXT
    end

    field :merge_source_status, Types::ContributorMergeSourceStatusType, null: false do
      description <<~TEXT
      The status of this contributor in the context of being a merge source.
      TEXT
    end

    field :merge_target, self, null: true do
      description <<~TEXT
      The target of the merge, if available.
      TEXT
    end

    field :merge_target_status, Types::ContributorMergeTargetStatusType, null: false do
      description <<~TEXT
      The status of this contributor in the context of being a merge target.
      TEXT
    end

    load_association! :contributor_user_link, as: :user_link
    load_association! :merge_target

    expose_authorization_rule :claim?, <<~TEXT
    Whether the current user has the ability to claim this contributor profile as their own.

    This requires both that the user has permission to manage the system broadly,
    and that they do not already have a contributor profile linked to their account.

    It also requires the contributor to be unclaimed.

    It is associated with the `contributorClaim` mutation.
    TEXT

    expose_authorization_rule :link_user?, <<~TEXT
    Whether the current user has the ability to link this contributor profile to any user account.

    This differs from `canClaim` in that it does not require the contributor to be unclaimed,
    and can specify the user account to link to.

    It is associated with the `contributorUserLinkUpsert` mutation.
    TEXT

    expose_authorization_rule :merge_source?, <<~TEXT
    Whether the current user has the ability to use this contributor profile as a source in a merge operation.
    TEXT

    expose_authorization_rule :merge_target?, <<~TEXT
    Whether the current user has the ability to use this contributor profile as a target in a merge operation.
    TEXT

    # @return [<Contributors::Link>]
    def links
      Array(object.links).compact
    end
  end
end
