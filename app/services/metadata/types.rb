# frozen_string_literal: true

module Metadata
  module Types
    extend ::Support::Typespace

    EnumeratedStringList = Coercible::Array.of(Coercible::String.constrained(filled: true))

    GroupedContributionMapping = Hash.map(Coercible::String.constrained(filled: true), Coercible::Symbol.constrained(filled: true))

    NamaeValue = Instance(::Namae::Name)

    NamaeValues = Array.of(NamaeValue)

    NamespacePrefix = String.constrained(filled: true) | Nil

    NamespaceValue = String.constrained(filled: true)

    NamespaceMap = Hash.map(NamespacePrefix, NamespaceValue)
  end
end
