# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::Users
    class UserFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `User` records.
      TEXT

      inherit_from!(::Filtering::Scopes::Users)

      argument :email, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Look for an exact email match.
        TEXT
      end
    end
  end
end
