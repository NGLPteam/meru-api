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
    implements ::Types::SluggableType

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

    # @return [<Contributors::Link>]
    def links
      Array(object.links).compact
    end
  end
end
