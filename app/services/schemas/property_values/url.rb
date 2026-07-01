# frozen_string_literal: true

module Schemas
  module PropertyValues
    # This serves as a struct that wraps around URL property values
    # and provides a more fluent interface than a hash.
    #
    # @see Schemas::Properties::Scalar::URL
    # @see Schemas::Properties::Types::NormalizedURL
    # @see Schemas::Properties::Types::URLShape
    # @see Templates::Drops::URLDrop
    class URL < Support::FlexibleStruct
      include Dry::Core::Equalizer.new(:href)
      include Support::CallsCommonOperation

      DEFAULT_LABEL = Schemas::Properties::Types::DEFAULT_URL_LABEL

      attribute :href, Types::String.constrained(http_uri: true)
      attribute :label, Types::String
      attribute? :title, Types::String.optional

      def blank?
        href.blank? || label.blank?
      end

      # @return [String]
      def anchor_tag
        # simplecov:disable
        return "" if blank?
        # simplecov:enable

        call_operation("templates.mdx.build_anchor", href:, label:, title:).value_or(nil)
      end

      class << self
        # @param [Hash, String, nil] raw_value
        # @return [Schemas::PropertyValues::URL, nil]
        def normalize(raw_value)
          case raw_value
          when self
            # simplecov:disable
            raw_value
            # simplecov:enable
          when Schemas::Properties::Types::URLShape
            coerced = Schemas::Properties::Types::URLShape[raw_value]

            new(**coerced)
          when Schemas::Properties::Types::HypertextURL
            new(href: raw_value, label: DEFAULT_LABEL)
          end
        end
      end
    end
  end
end
