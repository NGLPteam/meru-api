# frozen_string_literal: true

module Support
  module Schemas
    module Types
      include Dry.Types

      EnumClass = Class.constrained(inherits: ::GraphQL::Schema::Enum)

      SafeString = Coercible::String

      # A dry-type with GQL typing
      Type = ::Support::Types::DryType.constrained(gql_typing: true)
    end
  end
end
