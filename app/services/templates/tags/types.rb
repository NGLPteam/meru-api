# frozen_string_literal: true

module Templates
  module Tags
    module Types
      extend ::Support::Typespace

      ArgName = Coercible::Symbol.constrained(filled: true)

      ArgNames = Coercible::Array.of(ArgName)
    end
  end
end
