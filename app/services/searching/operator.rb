# frozen_string_literal: true

module Searching
  # @abstract
  class Operator
    extend ActiveModel::Callbacks

    include Searching::EncodesJoin

    include Dry::Core::Memoizable
    include Dry::Effects::Handler.Interrupt(:skip, as: :catch_skip)
    include Dry::Effects.Interrupt(:skip)
    include Dry::Initializer[undefined: false].define -> do
      param :left, Searching::Types::Any
      param :right, Searching::Types::Any
    end

    include ArelHelpers

    include Shared::Typing

    define_model_callbacks :prepare, :compile

    delegate :value_column, :type, to: :property, allow_nil: true, prefix: true

    # @return [Hash]
    attr_reader :joins

    # @return [Arel::Expressions, nil]
    attr_reader :expression

    # @return [Arel::Expressions, nil]
    def call(joins: {})
      @joins = joins

      run_callbacks :prepare do
        prepare!
      end

      run_callbacks :compile do
        @expression = compile
      end

      return @expression
    rescue Searching::Skip
      # :nocov:
      return nil
      # :nocov:
    end

    # @!attribute [r] property
    # @return [Schemas::Properties::Path, Searching::CoreProperty]
    memoize def property
      case left
      when Searching::CoreProperty::PATTERN
        Searching::CoreProperty.parse left
      when Schemas::Properties::ParsePath::PATTERN
        MeruAPI::Container["schemas.properties.parse_path"].(left).value_or(nil)
      else
        # :nocov:
        raise Searching::Skip
        # :nocov:
      end
    end

    memoize def search_strategy
      case property
      when Searching::CoreProperty, Schemas::Properties::Path
        property.search_strategy
      else
        # :nocov:
        "none"
        # :nocov:
      end
    end

    memoize def arelized_path
      case property
      when Searching::CoreProperty, Schemas::Properties::Path
        case property.search_strategy
        when "named_variable_date"
          join_for_variable_date property.full_path
        when "text"
          join_for_schematic_text property.full_path
        else
          join_for_searchable_property property.full_path
        end
      else
        # :nocov:
        arel_quote(nil)
        # :nocov:
      end
    end

    memoize def arelized_value
      case search_strategy
      when "named_variable_date"
        arelized_path[:value]
      when "text"
        arelized_path[:document]
      when "property"
        arelized_path[property.value_column]
      else
        # :nocov:
        arel_quote nil
        # :nocov:
      end
    end

    memoize def quoted_value
      arel_quote right
    end

    memoize def arel_table
      ::Entity.arel_table
    end

    memoize def named_variable_dates
      ::NamedVariableDate.arel_table
    end

    memoize def schematic_texts
      ::SchematicText.arel_table
    end

    memoize def searchable_properties
      ::EntitySearchableProperty.arel_table
    end

    # @abstract
    # @return [void]
    def prepare!; end

    # @abstract
    # @return [Arel::Expressions]
    def compile
      # :nocov:
      raise "must implement"
      # :nocov:
    end

    # @param [Array<Searching::Operator>] operators
    # @return [Arel::Expressions, nil]
    def compile_nested(operators)
      operators.map { _1.(joins:) }.compact_blank.reduce(&:and)
    end

    # @return [Arel::Nodes::TableAlias]
    def join_for(path)
      joins[path] ||=
        begin
          join_name = encode_join(path)

          yield join_name
        end

      expr = joins.fetch(path)

      expr.left
    end

    def build_arel_join_for_entity_adjacent_table(table_alias)
      on_condition = arel_table[:hierarchical_type].eq(table_alias[:entity_type]).and(
        arel_table[:hierarchical_id].eq(table_alias[:entity_id])
      )

      # :nocov:
      on_condition = yield on_condition if block_given?
      # :nocov:

      on = Arel::Nodes::On.new on_condition

      Arel::Nodes::OuterJoin.new(table_alias, on)
    end

    # @param [String] path
    # @param [Arel::Table] target_table
    # @return [Arel::Nodes::TableAlias]
    def build_arel_join_for_entity_path_table(path, target_table)
      join_for path do |join_name|
        aliaz = target_table.alias(join_name)

        build_arel_join_for_entity_adjacent_table aliaz do |on|
          on.and aliaz[:path].eq(path)
        end
      end
    end

    def join_for_schematic_text(path)
      build_arel_join_for_entity_path_table path, schematic_texts
    end

    def join_for_searchable_property(path)
      build_arel_join_for_entity_path_table path, searchable_properties
    end

    def join_for_variable_date(path)
      build_arel_join_for_entity_path_table path, named_variable_dates
    end
  end
end
