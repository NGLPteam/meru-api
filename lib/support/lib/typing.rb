# frozen_string_literal: true

module Support
  # Automatically generate `::Type` and `::List` types for any class that includes this.
  module Typing
    extend ActiveSupport::Concern

    included do
      type = Support::Types.Instance(self)

      const_set :Type, type

      list = Support::Types::Array.of(type)

      const_set :List, list

      # subclass = Support::Types::Class.constrained(gteq: self)

      # const_set :Subclass, subclass
    end

    class_methods do
      # Generate a configurable "map" type with a certain type of key.
      #
      # @param [Dry::Types::Type] key
      # @param [Symbol] on
      def map_type!(key: Support::Types::Coercible::String, on: :Map)
        const_set on, Support::Types::Hash.map(key, const_get(:Type))
      end

      # @param [Class] type_klass the GraphQL type class to generate a corresponding GraphQL type for
      # @return [void]
      def with_gql_type!(type_klass)
        base_type = const_get(:Type)

        remove_const(:Type)

        const_set :Type, base_type.gql_type(type_klass)
      end
    end

    class << self
      # Allow our typing module to be applied to modules as well,
      # so we can more succinctly type interfaces.
      #
      # @param [Module] base
      # @return [void]
      def extend_object(mod)
        # :nocov:
        raise TypeError, "use #include for classes" if mod.kind_of?(Class)

        # Already extended
        return false if mod.singleton_class < self

        # :nocov:

        super

        mod.extend const_get(:ClassMethods)
        mod.class_eval(&@_included_block)
      end
    end
  end
end
