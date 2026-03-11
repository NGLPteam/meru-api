# frozen_string_literal: true

module FullText
  # Types tied to working with full-text references.
  #
  # @see SchematicText
  # @see Schemas::Properties::Scalar::FullText
  module Types
    extend ::Support::Typespace

    Kind = Coercible::String.enum("text", "markdown", "html").fallback("text").constructor do |value|
      value.to_s.underscore
    end

    Reference = Hash.schema(
      content?: String.optional,
      kind?: Kind.default("text"),
      lang?: String.optional,
    ).with_key_transform(&:to_sym)

    # @see FullText::Normalizer
    NormalizedReference = Reference.constructor do |value|
      MeruAPI::Container["full_text.normalizer"].call(value)
    end

    Map = Hash.map(String, Reference.optional)
  end
end
