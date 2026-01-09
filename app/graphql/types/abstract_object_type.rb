# frozen_string_literal: true

module Types
  # @abstract
  class AbstractObjectType < GraphQL::Schema::Object
    include Support::GraphQLAPI::Enhancements::AbstractObject

    include GraphQL::FragmentCache::Object

    def current_user_privileged?
      context[:current_user].try(:has_global_admin_access?)
    end
  end
end
