# frozen_string_literal: true

module ControlledVocabularies
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    NAMESPACE_PATTERN = /\A(?:[a-z]\w+[a-z0-9])(?:\.(?:[a-z]\w+[a-z0-9]))+\z/
    IDENTIFIER_PATTERN = /\A(?:[a-z]\w+[a-z0-9])\z/
    PROVIDES_PATTERN = /\A(?:[a-z]\w+[a-z0-9])\z/

    Input = Coercible::Hash

    Namespace = String.constrained(format: NAMESPACE_PATTERN, filled: true)
    Identifier = String.constrained(format: IDENTIFIER_PATTERN, filled: true)
    Provides = String.constrained(format: PROVIDES_PATTERN, filled: true)

    Name = String.constrained(filled: true, rails_present: true)

    Label = Name

    Description = String.optional

    URL = String.constrained(format: /\A#{Support::GlobalTypes::URL_PATTERN}\z/)

    Version = AppTypes::SemanticVersion

    # @!group Models

    Root = ModelInstance("ControlledVocabulary")

    Item = ModelInstance("ControlledVocabularyItem")

    Source = ModelInstance("ControlledVocabularySource")

    # @!endgroup
  end
end
