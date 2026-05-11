# frozen_string_literal: true

module Support
  module Filtering
    module Types
      extend ::Support::Typespace

      # A type representing options that can be passed to a filter runner.
      #
      # @return [Dry::Types::Type]
      FilterOptions = Hash.map(Coercible::Symbol, Any)

      # A type representing the input hash for filtering arguments.
      #
      # @return [Dry::Types::Type]
      Input = Hash.fallback { Dry::Core::Constants::EMPTY_HASH }

      # A type representing an ActiveRecord scope / relation.
      #
      # @return [Dry::Types::Type]
      Scope = ::Support::Types::Relation

      # A type representing the name of a filtering scope, which corresponds to a method on the model's ActiveRecord::Relation.
      #
      # @return [Dry::Types::Type]
      ScopeName = Symbol

      # A list of {ScopeName}s.
      #
      # @return [Dry::Types::Type]
      ScopeNames = Array.of(ScopeName)
    end
  end
end
