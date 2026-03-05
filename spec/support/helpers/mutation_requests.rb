# frozen_string_literal: true

require_relative "hash_setter"
require_relative "graphql_helpers"

module TestHelpers
  MutationInputHelpers = TestHelpers::HashSetter.new :mutation_input

  module MutationExampleHelpers
    def wrap_mutation_query(query, **options)
      self.class.wrap_mutation_query(query, **options)
    end
  end

  module MutationSpecHelpers
    # @note Implies `error: true`: we must always be testing mutation errors.
    # @param [String] raw_query
    # @param [Boolean] auth_result whether to include the authorization result fragment in the query
    # @return [void] defines a let variable `query` with the wrapped query
    def mutation_query!(raw_query, **options)
      wrapped_query = wrap_mutation_query raw_query, **options

      let_it_be(:query) { wrapped_query }
    end

    # @note Implies `error: true`: we must always be testing mutation errors.
    # @param [String] raw_query
    # @param [Boolean] auth_result whether to include the authorization result fragment in the query
    # @return [String] the wrapped query
    def wrap_mutation_query(raw_query, **options)
      raise "Missing `... ErrorFragment` in mutation query" unless raw_query.include?("... ErrorFragment")

      wrap_graphql_query(raw_query, **options, error: true)
    end
  end
end

RSpec.shared_context "mutation requests" do
  include_context "with default graphql context"

  let(:graphql_variables) do
    {
      input: mutation_input
    }
  end
end

RSpec.configure do |config|
  config.include TestHelpers::MutationInputHelpers, graphql: :mutation
  config.include TestHelpers::MutationExampleHelpers, graphql: :mutation
  config.extend TestHelpers::MutationSpecHelpers, graphql: :mutation
  config.include_context "mutation requests", graphql: :mutation
end
