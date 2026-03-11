# frozen_string_literal: true

module Mappers
  module Types
    extend ::Support::Typespace

    include Support::EnhancedTypes

    DryType = Instance(::Dry::Types::Type)

    Nulls = Coercible::String.default("last").enum("last", "first").fallback("last")
  end
end
