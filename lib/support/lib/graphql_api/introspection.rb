# frozen_string_literal: true

module Support
  module GraphQLAPI
    module Introspection
      # A custom `GraphQL::Introspection::DynamicFields` that bypasses auth checks,
      # since these are not things we authorize and they use up a lot of request time
      # in intermittent bursts.
      #
      # @see https://github.com/rmosolgo/graphql-ruby/pull/3446
      class DynamicFields < ::GraphQL::Introspection::DynamicFields
        extend Support::GraphQLAPI::DisableAuthChecks
      end
    end
  end
end
