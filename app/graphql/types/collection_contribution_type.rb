# frozen_string_literal: true

module Types
  class CollectionContributionType < Types::BaseModel
    implements Types::ContributionType

    description "A contribution to a collection"

    field :collection, "Types::CollectionType", null: false
    field :contributor, "Types::ContributorType", null: false
  end
end
