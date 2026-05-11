# frozen_string_literal: true

# The top level module for the `Filtering` subsystem.
#
# The primary purpose of this subsystem is to provide
# a declarative interface for building filters on ActiveRecord
# models, and integrating those filters into GraphQL queries.
#
# The main entry point for defining filters is the
# {Filtering::FilterScope} class, which provides a DSL for
# defining filtering arguments and applying them to an
# ActiveRecord scope.
#
# It has a tight integration with the {Resolvers} subsystem,
# allowing filters to be easily added to GraphQL queries by
# providing a scope to {Resolvers::AbstractResolver.filters_with!}.
#
# @see Filtering::FilterScope
module Filtering
  # A submodule containing input types for filtering.
  module Inputs
  end

  # A submodule containing actual {Filtering::FilterScope} implementations.
  module Scopes
  end
end
