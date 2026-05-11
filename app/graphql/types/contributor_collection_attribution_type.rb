# frozen_string_literal: true

module Types
  # @see ContributorCollectionAttribution
  class ContributorCollectionAttributionType < Types::BaseModel
    description <<~TEXT
    A specific attribution on a `Collection`.
    TEXT

    implements Types::ContributorAttributionType

    field :collection, Types::CollectionType, null: false do
      description "The collection the contributor has an attribution on."
    end

    load_association! :collection

    load_association! :collection_roles, as: :roles
  end
end
