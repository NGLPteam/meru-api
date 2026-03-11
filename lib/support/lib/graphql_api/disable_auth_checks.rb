# frozen_string_literal: true

module Support
  module GraphQLAPI
    # A tremendous amount of time in GraphQL requests is spent on `Controller/GraphQL/Authorized/DynamicFields`,
    # and possibly elsewhere. These are not things we authorize.
    #
    # @see https://github.com/rmosolgo/graphql-ruby/pull/3446
    module DisableAuthChecks
      # @note This bypasses auth checks for the type.
      def authorized_new(obj, ctx) = new(obj, ctx)
    end
  end
end
