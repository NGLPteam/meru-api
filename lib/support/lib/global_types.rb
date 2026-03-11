# frozen_string_literal: true

module Support
  # Types that are shared between support code and application code.
  module GlobalTypes
    extend ::Support::Typespace

    UUID_PATTERN = /\A[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\z/i

    UUID = String.constrained(format: UUID_PATTERN)

    EMAIL_PATTERN = URI::MailTo::EMAIL_REGEXP

    SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/

    URL_PATTERN = URI::DEFAULT_PARSER.make_regexp(%w[http https]).freeze

    UUIDList = Array.of(UUID).constrained(min_size: 1)

    IntList = Array.of(Integer)

    StringList = Array.of(String)

    CoercibleString = Coercible::String

    CoercibleStringList = Coercible::Array.of(Coercible::String)

    BlankString = String.constrained(rails_blank: true)

    Path = Instance(::Pathname)

    Position = Coercible::Integer.constrained(gteq: 0)

    SimpleSortDirection = Coercible::String.default("asc").enum("asc", "desc").fallback("asc")

    Slug = String.constrained(format: SLUG_PATTERN)

    GraphQLTypeClass = Inherits(::GraphQL::Schema::Object)

    GraphQLEdgeClass = Inherits(::GraphQL::Types::Relay::BaseEdge)

    GraphQLConnectionClass = Inherits(::GraphQL::Types::Relay::BaseConnection)
  end
end
