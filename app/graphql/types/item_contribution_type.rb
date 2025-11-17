# frozen_string_literal: true

module Types
  class ItemContributionType < Types::AbstractModel
    implements Types::ContributionType

    description "A contribution to an item"

    field :contributor, "Types::ContributorType", null: false
    field :item, "Types::ItemType", null: false
  end
end
