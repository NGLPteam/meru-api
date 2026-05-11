# frozen_string_literal: true

# Example GraphQL Queries served up on `/graphql/example_queries`.
class ExampleQuery < Support::FrozenRecordHelpers::AbstractRecord
  # Let's keep identifiers nice and predictable.
  IDENTIFIER_FORMAT = /\A[a-z][a-z-]+[a-z]\z/

  self.primary_key = :identifier

  add_index :identifier, unique: true

  schema! do
    required(:identifier).filled(:string) do
      format?(IDENTIFIER_FORMAT)
    end

    required(:description).filled(:string)

    required(:query).filled(:string)
  end

  class << self
    def assign_defaults!(record)
      example_query_file = "#{record['identifier']}.graphql"

      example_query_path = example_queries_path.join example_query_file

      record["query"] = example_query_path.read

      super
    end

    # @todo Replace with engine path resolution once extracted.
    def example_queries_path
      @example_queries_path ||= Rails.root.join("lib", "example_queries")
    end
  end
end
