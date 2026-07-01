# frozen_string_literal: true

module Schemas
  module PropertyValues
    # This serves as a struct that wraps around FullText property values
    # and provides a more fluent interface than a hash.
    #
    # @see ::FullText::Normalizer
    # @see Schemas::Properties::Scalar::FullText
    # @see Templates::Drops::FullTextDrop
    class FullText < Support::FlexibleStruct
      include Support::CallsCommonOperation

      attribute? :content, Types::Coercible::String.default("")
      attribute? :kind, ::FullText::Types::Kind
      attribute? :lang, Types::Coercible::String.default("")

      delegate :blank?, to: :content

      class << self
        # @param [String, nil] content
        # @return [Schemas::PropertyValues::FullText]
        def markdown(content)
          new(content:, kind: "markdown")
        end

        # @param [Hash, String, nil] reference
        # @return [Schemas::PropertyValues::FullText]
        def normalize(raw_value)
          case raw_value
          when self
            # simplecov:disable
            raw_value
            # simplecov:enable
          else
            coerced = MeruAPI::Container["full_text.normalizer"].(raw_value)

            new(**coerced)
          end
        end
      end
    end
  end
end
