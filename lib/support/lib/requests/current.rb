# frozen_string_literal: true

module Support
  module Requests
    # Current request attributes for GraphQL requests.
    class Current < ActiveSupport::CurrentAttributes
      attribute :current_user, default: proc { AnonymousUser.new }
      attribute :graphql_kind, default: -> { "other" }
      attribute :graphql_operation_name
      attribute :graphql_steps, default: -> { [] }
      attribute :request_id
      attribute :state, default: -> { Support::Requests::State.new }

      def active? = request_id.present?
    end
  end
end
