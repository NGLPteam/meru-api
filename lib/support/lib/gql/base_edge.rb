# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseEdge < ::Support::GQL::AbstractObject
      # add `node` and `cursor` fields, as well as `node_type(...)` override
      include ::GraphQL::Types::Relay::EdgeBehaviors

      node_nullable false
    end
  end
end
