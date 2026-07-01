# frozen_string_literal: true

module Support
  class NormalizeGQLType
    extend Dry::Core::Cache

    # @param [String, nil] input
    # @return [String]
    def call(input)
      return "String" if input.blank?

      fetch_or_store input do
        parse input
      end
    end

    private

    def parse(input)
      # simplecov:disable

      raise TypeError, "unknown type: #{input}" unless input.kind_of?(::String)

      # simplecov:enable

      case input
      when /\Astring\z/i, /\A(?:ci)?text\z/i
        "String"
      when /\Aint(?:eger)?\z/i
        "Int"
      when /\Afloat\z/i, /\Anumeric\z/i, /\Adecimal\z/i
        "Float"
      when /\Abigint\z/i
        "BigInt"
      when /\A(?:iso8601)?date\z/i
        "ISO8601Date"
      when /\A(?:(?:iso8601)?date)?time\z/i
        "ISO8601DateTime"
      when /\Ajson\z/i
        "JSON"
      when /\Aid\z/i
        "ID"
      when /\Abool(?:ean)?\z/i
        "Boolean"
      when /\Aslug\z/i
        "Support::GQL::SlugType"
      when /[^:]+::[^:]+/
        # This should be a fully-realized path
        "::#{input}"
      else
        try_fallbacks_for input
      end
    end

    def try_fallbacks_for(input)
      classified = input.classify

      raw_candidates = [
        "::Types::#{input}",
        "::Types::#{classified}"
      ]

      candidates = raw_candidates.flat_map do |candidate|
        [candidate, "#{candidate}Type"]
      end

      found = candidates.detect do |candidate|
        candidate.safe_constantize.present?
      end

      return found if found

      default = input.match?(/[A-Z]/) ? candidates.second : candidates.fourth

      warn "unknown type: #{input}, falling back to #{default}"

      return default
    end
  end
end
