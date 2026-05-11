# frozen_string_literal: true

module Types
  class UserGroupCollectionAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserGroupAccessGrantType

    description <<~TEXT
    An access grant for a group to a collection.
    TEXT

    field :collection, "Types::CollectionType", null: false do
      description "The collection to which a group has been granted access"
    end
  end
end
