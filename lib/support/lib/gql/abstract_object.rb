# frozen_string_literal: true

module Support
  module GQL
    # @abstract A base type for all VOG GraphQL object-likes that ultimately inherit from `GraphQL::Schema::Object`.
    class AbstractObject < ::GraphQL::Schema::Object
      include ::Support::CallsCommonOperation
      include ::Support::GraphQLAPI::Enhancements::AbstractObject

      include ::GraphQL::FragmentCache::Object

      def current_user_privileged?
        context[:current_user].try(:has_global_admin_access?)
      end
    end
  end
end
