# frozen_string_literal: true

module Resolvers
  # Types in support of the {Resolvers} subsystem.
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    # A filter scope for use in GraphQL resolvers.
    #
    # @see Filtering::FilterScope
    FilterScopeKlass = Inherits(::Filtering::FilterScope)

    # A reorderer for use in GraphQL resolvers.
    #
    # We reorder some params for better display and introspection,
    # ensuring that higher-priority keys are put at the top of the
    # params hash.
    ParamsReorderer = ::Support::Types::ParamsReorderer
  end
end
