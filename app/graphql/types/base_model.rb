# frozen_string_literal: true

module Types
  # @abstract The base model type for all VOG GraphQL object types that represent application models.
  class BaseModel < ::Types::BaseObject
    include ::Support::GraphQLAPI::BaseModelInterface
  end
end
