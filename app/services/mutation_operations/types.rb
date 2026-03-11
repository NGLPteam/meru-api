# frozen_string_literal: true

module MutationOperations
  # Types for working with mutation operations, contracts, etc.
  module Types
    extend ::Support::Typespace

    ArgKey = Coercible::Symbol.constrained(format: /\A[a-z][a-z0-9_]+\z/)

    AuthPredicate = Coercible::Symbol.constrained(format: /\A[a-z][a-z0-9_]+\?\z/)

    # The "verb" the contract does
    ContractVerb = Coercible::Symbol.enum(:create, :update, :destroy, :mutate).fallback(:mutate)
  end
end
