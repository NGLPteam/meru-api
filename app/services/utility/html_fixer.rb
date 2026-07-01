# frozen_string_literal: true

module Utility
  # @see Utility::FixPossibleHTML
  class HTMLFixer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :input, ::Utility::Types::Coercible::String
    end

    ESCAPED_HTML_PATTERNS = [
      /&lt;/,
      /&gt;/,
      /&#x[a-f0-9]+;/i,
    ].freeze

    standard_execution!

    # @return [Boolean]
    attr_reader :has_escaped_html

    alias has_escaped_html? has_escaped_html

    # @return [String]
    attr_reader :output

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield process!
      end

      Success output
    end

    wrapped_hook! def process
      @has_escaped_html = detect_escaped_html?

      @output = has_escaped_html? ? unescaped_input : input.dup.freeze

      super
    end

    private

    def detect_escaped_html?
      # simplecov:disable
      return false if input.blank?
      # simplecov:enable

      ESCAPED_HTML_PATTERNS.any? do |pattern|
        pattern.match? input
      end
    end

    def unescaped_input
      CGI.unescapeHTML(input)
    end
  end
end
