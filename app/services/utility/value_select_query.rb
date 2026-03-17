# frozen_string_literal: true

module Utility
  # A helper for building a `SELECT * FROM (VALUES (...)), ... ) AS tbl (col1, col2, ...)` query with proper type casts.
  class ValueSelectQuery
    include Dry::Initializer[undefined: false].define -> do
      param :values, ::Utility::Types::ValueSelectValues

      option :casts, ::Utility::Types::ValueSelectCasts, default: proc { Dry::Core::Constants::EMPTY_HASH }
      option :table_name, ::Utility::Types::String, default: proc { "tbl" }
      option :model_class, ::Support::Models::Types::ModelClass.optional, optional: true
    end

    DEFAULT_TYPE = ActiveRecord::Type::Value.new.freeze

    # We won't bother casting columns with these types,
    # since PG will figure it out.
    SKIPPABLE_CASTS = [
      nil,
      :boolean,
      :string,
      :citext,
      :text
    ].freeze

    # @return [Hash{Symbol => Symbol}]
    attr_reader :column_casts

    # @return [Array<Symbol>]
    attr_reader :column_names

    # @return [Hash{Symbol => ActiveRecord::Type}]
    attr_reader :column_types

    # @return [<String>]
    attr_reader :quoted_columns

    # @return [<<Arel::Nodes::SqlLiteral>>]
    attr_reader :quoted_values

    # @return [Arel::Table]
    attr_reader :table

    # @return [Arel::Nodes::ValuesList]
    attr_reader :values_list

    def initialize(...)
      super

      compile_columns!

      compile_values_list!

      compile_query!
    end

    def to_sql = @query.to_sql

    private

    # @return [void]
    def compile_columns!
      @column_names = values.reduce([]) { |n, v| n | v.keys }

      @column_types = column_names.index_with { |name| model_class&.type_for_attribute(name.to_s) || DEFAULT_TYPE }

      @column_casts = column_names.index_with { |name| normalize_cast(casts[name] || default_column_cast_for(name)) }

      @quoted_columns = column_names.map { |name| quote_column(name) }

      @table = Arel::Table.new(table_name)
    end

    # @return [void]
    def compile_values_list!
      @quoted_values = quote_values

      @values_list = Arel::Nodes::Grouping.new(Arel::Nodes::ValuesList.new(quoted_values))
    end

    def compile_query!
      source = Arel::Nodes::As.new(values_list, Arel.sql("#{table_name}(#{quoted_columns.join(", ")})"))

      projections = column_names.map do |name|
        cast = column_casts[name]

        quoted = quote_column(name)

        next quoted unless cast

        Arel.sql("CAST(#{quoted} AS #{cast}) AS #{quoted}")
      end

      @query = table.project(*projections).from(source)
    end

    def connection = ActiveRecord::Base.connection

    # @param [Symbol] attribute
    # @return [String, nil]
    def default_column_cast_for(attribute)
      return unless model_class

      column = model_class.columns_hash[attribute.to_s]

      stm = column&.sql_type_metadata

      return if stm.blank? || stm.type.in?(SKIPPABLE_CASTS)

      stm.sql_type
    end

    def normalize_cast(input)
      case input
      when :json then :jsonb
      when :string, :citext then nil
      else input
      end
    end

    def quote_column(name) = connection.quote_column_name(name)

    def quote_value(value) = connection.quote(value)

    # @return [<<Arel::Nodes::SqlLiteral>>]
    def quote_values
      values.map do |value_hash|
        column_names.map do |name|
          serialized = column_types[name].serialize(value_hash[name])

          quoted = quote_value(serialized)

          Arel.sql(quoted)
        end
      end
    end
  end
end
