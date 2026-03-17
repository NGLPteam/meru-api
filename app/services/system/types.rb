# frozen_string_literal: true

module System
  module Types
    extend ::Support::Typespace

    Query = String.constrained(filled: true)

    GraphQLVariables = Hash.map(Coercible::String, Types::Any)

    VisibilityProfile = Symbol.enum(:public)
  end
end
