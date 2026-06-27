# frozen_string_literal: true

module Support
  module ClassyList
    module Types
      extend Support::Typespace

      # A very loose type representing a method name.
      #
      # @return [Dry::Types::Type(Symbol)]
      MethodName = Coercible::Symbol.constrained(format: /\A[a-z][a-z0-9_]+[?!]?\z/i)

      # A type representing an array of method names.
      #
      # @return [Dry::Types::Type(Array<Symbol>)]
      MethodNames = Array.of(MethodName)

      RealizeMode = Symbol.default(:none).enum(:none, :hash, :array)
    end
  end
end
