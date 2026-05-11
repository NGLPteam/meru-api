# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseEnum < ::GraphQL::Schema::Enum
      include ::Support::GraphQLAPI::Enhancements::Enum
    end
  end
end
