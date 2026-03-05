# frozen_string_literal: true

module Support
  module GraphQLAPI
    # @see https://github.com/palkan/action_policy-graphql
    module AuthHelpers
      extend ActiveSupport::Concern

      included do
        include ActionPolicy::GraphQL::Behaviour
      end
    end
  end
end
