# frozen_string_literal: true

module Support
  class NormalizeGQLFields
    include Support::Deps[
      normalize_type: "normalize_gql_type",
    ]

    PATTERN = /\A(?<name>\w+)(?::(?<type>[^!\s]+?)(?<not_null>!)?)?\z/

    # @param [<String>] fields
    # @return [<Support::NormalizedGQL::Field>]
    def call(*fields)
      fields.flatten!

      fields.map do |field|
        parse field
      end
    end

    private

    def parse(field)
      case field
      when PATTERN
        name = Regexp.last_match[:name]
        type = normalize_type.(Regexp.last_match[:type])
        null = Regexp.last_match[:not_null].blank?

        Support::NormalizedGQL::Field.new(name:, type:, null:)
      else
        # simplecov:disable
        raise "Unsupported field: #{field}"
        # simplecov:enable
      end
    end
  end
end
