# frozen_string_literal: true

module Types
  class UserGroupItemAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserGroupAccessGrantType

    description <<~TEXT
    An access grant for a group to a item.
    TEXT

    field :item, "Types::ItemType", null: false do
      description "The item to which a group has been granted access"
    end
  end
end
