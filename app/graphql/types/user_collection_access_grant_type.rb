# frozen_string_literal: true

module Types
  class UserCollectionAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserAccessGrantType

    description <<~TEXT
    An access grant for a user to a collection.
    TEXT

    field :collection, "Types::CollectionType", null: false do
      description "The collection to which a user has been granted access"
    end
  end
end
