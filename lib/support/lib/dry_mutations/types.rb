# frozen_string_literal: true

module Support
  module DryMutations
    module Types
      extend ::Support::Typespace

      AttributePath = Array.of(Integer | Coercible::String)
    end
  end
end
