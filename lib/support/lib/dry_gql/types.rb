# frozen_string_literal: true

module Support
  module DryGQL
    module Types
      extend ::Support::Typespace

      EnumClass = Class.constrained(inherits: ::GraphQL::Schema::Enum)

      LazyLoadTypeName = String.constrained(format: /\A(?:::)?Types::[A-Z]\S+\z/)

      SchemaMember = Class.constrained(inherits: ::GraphQL::Schema::Member)

      TypeReference = LazyLoadTypeName | SchemaMember

      # A dry-type with GQL typing
      Type = ::Support::Types::DryType.constrained(gql_typing: true)
    end
  end
end
