# frozen_string_literal: true

# Methods for detecting whether changes to a model are happening
# within the context of a GraphQL Mutation
#
# The predicate to use in lifecycles is {#in_graphql_mutation?}.
#
# @see Mutations.with_active
# @see Mutations::Current
module ModelMutationSupport
  extend ActiveSupport::Concern

  # @!attribute [r] graphql_mutation_active
  #   @see Mutations::Current
  #   @return [Boolean] whether the current context is within an active GraphQL mutation
  def graphql_mutation_active = ::Mutations::Current.active

  alias graphql_mutation_active? graphql_mutation_active

  # An attribute that simulates a GraphQL mutation being active for testing/console use.
  # It serves as a fallback for {#graphql_mutation_active?} in {#in_graphql_mutation?}.
  #
  # @return [Boolean]
  attr_accessor :pretend_graphql_mutation_active

  alias pretend_graphql_mutation_active? pretend_graphql_mutation_active
  alias pretending_graphql_mutation_active? pretend_graphql_mutation_active

  # This will either detect from the dry-effect or it will use {#pretend_graphql_mutation_active}
  def in_graphql_mutation?
    graphql_mutation_active? || pretend_graphql_mutation_active?
  end

  # @return [void]
  def with_active_mutation!(&)
    Mutations.with_active!(&)
  end
end
