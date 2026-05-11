# frozen_string_literal: true

module Types
  class UserItemAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserAccessGrantType

    description <<~TEXT
    An access grant for a user to a collection.
    TEXT

    field :item, "Types::ItemType", null: false do
      description "The item to which a user has been granted access"
    end
  end
end
