# frozen_string_literal: true

module Types
  class UserCommunityAccessGrantType < Types::BaseModel
    implements Types::AccessGrantType
    implements Types::UserAccessGrantType

    description <<~TEXT
    An access grant for a user to a community.
    TEXT

    field :community, "Types::CommunityType", null: false do
      description "The community to which a user has been granted access"
    end
  end
end
