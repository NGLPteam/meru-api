# frozen_string_literal: true

module Support
  module TypedSets
    # Types used with {Support::TypedSet}.
    #
    # @api private
    module Types
      extend ::Support::Typespace

      ConstName = Coercible::Symbol.constrained(format: /\A[A-Z]\w+[a-zA-Z]\z/)

      MethodName = Coercible::Symbol.constrained(format: /\A[a-z]\w+[a-z]\z/)

      Type = Instance(::Dry::Types::Type)
    end
  end
end
