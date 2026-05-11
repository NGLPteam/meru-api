# frozen_string_literal: true

module Filtering
  module Types
    extend ::Support::Typespace

    # A type representing the input hash for filtering arguments.
    Input = Hash.fallback { Dry::Core::Constants::EMPTY_HASH }

    # A type representing an ActiveRecord scope / relation.
    Scope = Support::Types::Relation

    # A type representing the name of a filtering scope, which corresponds to a method on the model's ActiveRecord::Relation.
    ScopeName = Symbol

    # A list of {ScopeName}s.
    ScopeNames = Array.of(ScopeName)
  end
end
