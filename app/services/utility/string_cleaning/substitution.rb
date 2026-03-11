# frozen_string_literal: true

module Utility
  module StringCleaning
    # @api private
    #
    # A substitution entry for a {Utility::StringCleaner}.
    class Substitution < Dry::Struct
      include ::Support::Typing

      Pattern = Support::GlobalTypes.Instance(::Regexp) | Dry::Types["string"]

      attribute :pattern, Pattern
      attribute :replacement, Dry::Types["string"].default("").fallback("")

      # @param [String] input
      # @return [String]
      def call(input)
        input.gsub(pattern, replacement)
      end
    end
  end
end
