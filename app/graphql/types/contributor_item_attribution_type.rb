# frozen_string_literal: true

module Types
  # @see ContributorItemAttribution
  class ContributorItemAttributionType < Types::BaseModel
    description <<~TEXT
    A specific attribution on a `Item`.
    TEXT

    implements Types::ContributorAttributionType

    field :item, Types::ItemType, null: false do
      description "The item the contributor has an attribution on."
    end

    load_association! :item

    load_association! :item_roles, as: :roles
  end
end
