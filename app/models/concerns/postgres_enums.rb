# frozen_string_literal: true

# A method for working with postgres enums that is cleaner than
# the default approach of Rails' `enum` method. We always want
# string values, not numeric.
module PostgresEnums
  extend ActiveSupport::Concern

  # A pattern for recognizing enum creation statements in structure.sql
  POSTGRES_ENUM_PATTERN = /
  (?<stmt>CREATE\s+TYPE\s+(?:"?(?<schema>\w+)"?\.)"?(?<enum>\S+)"?\s+AS\s+ENUM\s+\((?<values>[^)]+?)\))
  /xm

  class << self
    # @api private
    # @return [ActiveSupport::HashWithIndifferentAccess{ #to_s => <String> }]
    def fetch_pg_enum_definitions
      schema = Rails.root.join("db/structure.sql").read

      results = schema.scan POSTGRES_ENUM_PATTERN

      results.map(&:first).each_with_object({}.with_indifferent_access) do |statement, defs|
        parsed = PgQuery.parse statement

        create_enum = parsed.tree.stmts[0].stmt.create_enum_stmt

        enum_name = create_enum.type_name[1].string.sval

        values = create_enum.vals.map { |val| val.string.sval }

        defs[enum_name] = values
      end
    end
  end

  class_methods do
    @@pg_enum_definitions = PostgresEnums.fetch_pg_enum_definitions.freeze

    # @param [#to_s] enum_name
    # @param [String, Symbol] default
    # @param [Boolean] symbolize
    # @return [Dry::Types::Type]
    def dry_pg_enum(enum_name, default: nil, symbolize: false)
      values = pg_enum_values(enum_name)

      dry_pg_enum_base_type(symbolize:).then do |type|
        if default.present? && default.in?(values)
          type.default(default.freeze)
        else
          type
        end
      end.then do |type|
        type.enum(*Support::GlobalTypes::Coercible::Array.of(type)[values])
      end
    rescue KeyError
      # simplecov:disable
      # During migrations, etc. Allow any string or symbol.
      dry_pg_enum_base_type(symbolize:)
      # simplecov:enable
    end

    # @return [void]
    def pg_enum!(attr_name, as:, **options)
      values = pg_enum_values(as).to_h { |v| [v, v] }

      enum attr_name, values, **options
    rescue KeyError
      # simplecov:disable
      warn "Skipping enum definition for #{model_name}##{attr_name} (#{as.inspect}), not found, may be in migration"
      # simplecov:enable
    end

    # @!attribute [r] pg_enum_definitions
    # @return [ActiveSupport::HashWithIndifferentAccess{ #to_s => <String> }]
    def pg_enum_definitions
      @@pg_enum_definitions
    end

    # @param [#to_s] enum_name
    # @return [<String>]
    def pg_enum_values(enum_name)
      pg_enum_definitions.fetch(enum_name)
    end

    # @param [#to_s] enum_name
    # @return [<String>]
    def pg_enum_select_options(enum_name)
      values = pg_enum_values(enum_name)

      scope = "pg_enums.#{enum_name}"

      values.map do |value|
        [I18n.t(value, scope:, default: value.titleize), value]
      end
    rescue KeyError
      # simplecov:disable
      # During migrations, etc. Provide an empty set of options.
      []
      # simplecov:enable
    end

    private

    # @param [Boolean] symbolize
    def dry_pg_enum_base_type(symbolize: false)
      symbolize ? Support::GlobalTypes::Coercible::Symbol : Support::GlobalTypes::Coercible::String
    end
  end
end
