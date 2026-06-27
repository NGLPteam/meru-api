# frozen_string_literal: true

module Support
  module MessageMaps
    module Types
      extend Support::Typespace

      # A type representing a callable object, such as a Proc or an object that implements `#call`.
      #
      # @return [Dry::Types::Type(#call)]
      Callable = Interface(:call)

      # A very loose type representing a method name.
      #
      # @return [Dry::Types::Type(Symbol)]
      MethodName = Coercible::Symbol.constrained(format: /\A[a-z][a-z0-9_]+[?!]?\z/i)

      # A type representing an array of method names.
      #
      # @return [Dry::Types::Type(Array<Symbol>)]
      MethodNames = Array.of(MethodName)

      Message = Callable | MethodName

      # A type representing a mapping of method names to messages
      # that can be used to generate reified mappings
      #
      # @return [Dry::Types::Type({ Symbol => #call, Symbol })]
      Mapping = Types::Hash.map(MethodName, Message)
    end
  end
end
