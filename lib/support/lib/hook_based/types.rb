# frozen_string_literal: true

module Support
  module HookBased
    module Types
      extend ::Support::Typespace

      Attribute = Coercible::Symbol.constrained(format: /\A[a-z]\w*[a-z]\z/).freeze

      HookName = Coercible::Symbol.constrained(format: /\A[a-z]\w*[a-z]\z/).freeze
    end
  end
end
