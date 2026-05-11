# frozen_string_literal: true

module Types
  class UserGroupCommunityAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserGroupAccessGrantType

    description <<~TEXT
    An access grant for a group to a community.
    TEXT

    field :community, "Types::CommunityType", null: false do
      description "The community to which a group has been granted access"
    end
  end
end
