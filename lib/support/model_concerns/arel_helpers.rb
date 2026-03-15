# frozen_string_literal: true

module ArelHelpers
  INT_ARRAY = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveRecord::Type::Integer.new).freeze

  LTREE_TYPE = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::SpecializedString.new(:ltree)

  LTREE_ARRAY = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(LTREE_TYPE).freeze

  LQUERY_TYPE = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::SpecializedString.new(:lquery)

  LQUERY_ARRAY = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(LQUERY_TYPE).freeze

  TEXT_ARRAY = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveRecord::Type::Text.new).freeze

  MANY_ARRAY = Support::ArelExt::Types::ManyArray

  def arel_value_in_array(value, array)
    any_array = arel_named_fn("ANY", arel_quote(array))

    arel_quote(value).eq(any_array)
  end

  def arel_text_contains(field, value)
    arel_table[field].matches("%#{escape_ilike_needle(value)}%")
  end

  def escape_ilike_needle(needle)
    needle.gsub("%", "\\%").gsub("_", "\\_")
  end

  def arel_composite_attr(column, attribute)
    composite = arel_grouping(arel_attrify(column))

    arel_literal("(%s.#{attribute})" % [composite.to_sql])
  end

  def arel_ltree_contains(left, right)
    arel_infix "@>", arel_attrify(left), arel_quote(right)
  end

  def arel_ltree_matches(left, right)
    arel_infix ?~, arel_attrify(left), arel_quote(right)
  end

  def arel_ltree_matches_any_query(attribute, *queries)
    arel_infix(??, arel_attrify(attribute), arel_encode_lquery_array(*queries))
  end

  def arel_ltree_matches_one_or_any(left, right)
    case right
    when MANY_ARRAY
      arel_ltree_matches_any_query left, *right
    when Array
      arel_ltree_matches left, right.first
    else
      arel_ltree_matches left, right
    end
  end

  def arel_json_contains(attribute, **values)
    arel_infix "@>", arel_attrify(attribute), arel_cast(values.to_json, "jsonb")
  end

  def arel_json_has_key(attribute, key)
    arel_infix ??, arel_attrify(attribute), arel_quote(key)
  end

  def arel_json_get_path(attribute, *path_parts)
    raise "Must have at least one part" if path_parts.blank?

    arel_infix "#>", arel_attrify(attribute), arel_encode_text_array(*path_parts)
  end

  def arel_json_get_path_as_text(attribute, *path_parts)
    raise "Must have at least one part" if path_parts.blank?

    arel_infix "#>>", arel_attrify(attribute), arel_encode_text_array(*path_parts)
  end

  def arel_json_get(attribute, key)
    arel_infix "->", arel_attrify(attribute), arel_quote(key)
  end

  def arel_json_get_as_text(attribute, key)
    arel_infix "->>", arel_attrify(attribute), arel_quote(key)
  end

  def arel_json_cast_property(attribute, key, type)
    arel_cast(arel_json_get_as_text(attribute, key), type)
  end

  def arel_json_partial_update(attribute, **values)
    arel_infix "||", arel_attrify(attribute), arel_cast(values.to_json, "jsonb")
  end

  def arel_as(left, right)
    Arel::Nodes::As.new(left, right)
  end

  def arel_case(expr = nil, cast_to: nil, &block)
    statement = Arel::Nodes::Case.new(expr).tap(&block)

    if cast_to.present?
      arel_cast(statement, cast_to)
    else
      statement
    end
  end

  def arel_cast(value, type)
    arel_named_fn("CAST", arel_as(arel_quote(value), arel_literal(type)))
  end

  def arel_coalesce(*exprs)
    arel_named_fn("COALESCE", *exprs)
  end

  def arel_if_else(boolean_expr, truthy_expr, falsey_expr)
    arel_case do |stmt|
      stmt.when(arel_quote(boolean_expr)).then(arel_quote(truthy_expr))

      stmt.else(arel_quote(falsey_expr))
    end
  end

  def arel_infix(operator, left, right)
    Arel::Nodes::InfixOperation.new(operator, left, right)
  end

  def arel_literal(value)
    Arel.sql(value)
  end

  def arel_ltree(value)
    arel_cast(value, "ltree")
  end

  def arel_named_fn(name, *args)
    quoted_args = args.map { |arg| arel_quote(arg) }

    Arel::Nodes::NamedFunction.new name, quoted_args
  end

  def arel_not(expression)
    Arel::Nodes::Not.new expression
  end

  def arel_quote(arg)
    return arg if arg.kind_of?(Arel::Nodes::Node)

    Arel::Nodes.build_quoted arg
  end

  def arel_trigram_match(attr_or_column, input)
    attr = arel_attrify attr_or_column

    quoted = arel_quote input

    trigrams = arel_infix(?%, attr, quoted)

    similarity = arel_infix("%>", attr, quoted)

    trigrams.or(similarity)
  end

  # @see #arel_expr_in_query
  # @param [Symbol] attr (see #arel_attrify)
  # @param [#to_sql, #to_s] query
  # @return [Arel::Nodes::In]
  def arel_attr_in_query(attr, query)
    arel_expr_in_query arel_attrify(attr), query
  end

  # @param [#in] expr
  # @param [#to_sql, #to_s] query
  # @return [Arel::Nodes::In]
  def arel_expr_in_query(expr, query)
    wrapped_query = arel_quote_query query

    expr.in(wrapped_query)
  end

  # @param [#to_sql] query
  # @return [Arel::Nodes::SqlLiteral]
  def arel_quote_query(query)
    case query
    when Support::ArelExt::Types::ToSQL then arel_literal query.to_sql
    when String then arel_literal query
    else
      # :nocov:
      raise TypeError, "cannot quote query #{query.inspect}"
      # :nocov:
    end
  end

  def arel_encode_enum_array(*elements, enum_type:)
    arel_cast(arel_quote(LQUERY_ARRAY.serialize(elements.flatten)), "#{enum_type}[]")
  end

  def arel_encode_int_array(*elements)
    arel_cast(arel_quote(INT_ARRAY.serialize(elements.flatten)), "int[]")
  end

  def arel_encode_lquery_array(*elements)
    arel_cast(arel_quote(LQUERY_ARRAY.serialize(elements.flatten)), "lquery[]")
  end

  # @return [Arel::Nodes::Quoted]
  def arel_encode_ltree_array(*elements)
    arel_cast(arel_quote(LTREE_ARRAY.serialize(elements.flatten)), "ltree[]")
  end

  # @return [Arel::Nodes::Quoted]
  def arel_encode_text_array(*elements)
    arel_cast(arel_quote(TEXT_ARRAY.serialize(elements.flatten)), "text[]")
  end

  # @param [Arel::Nodes::Node] value
  # @return [Arel::Nodes::Grouping]
  def arel_grouped(value)
    Arel::Nodes::Grouping.new(value)
  end

  alias arel_grouping arel_grouped

  # @param [Arel::OrderPredications] expression
  # @param ["asc", "desc"] dir
  # @param ["first", "last", nil] nulls
  # @return [Arel::Nodes::Ordering]
  def arel_apply_order_to(expression, dir, nulls: nil)
    direction = Support::ArelExt::Types::SortDir[dir]

    nulls_value = Support::ArelExt::Types::NullsDir[nulls || direction]

    if direction == "desc"
      expression.desc
    else
      expression.asc
    end.then do |ordered|
      if nulls_value == "first"
        ordered.nulls_first
      else
        ordered.nulls_last
      end
    end
  end

  # Makes a more legible series of AND conditions.
  # @return [Arel::Nodes::Grouping(Arel::Nodes::And)]
  def arel_and_expressions(*expressions)
    expressions.flatten!

    return block_given? ? yield(expressions[0]) : expressions[0] if expressions.one?

    expressions.reduce do |grouping, expression|
      expression = yield expression if block_given?

      next grouping if expression.blank?

      if grouping.kind_of?(Arel::Nodes::Grouping)
        grouping.expr.and(expression)
      else
        # First expression
        grouping = yield grouping if block_given?

        grouping.and(expression)
      end
    end
  end

  # Makes a more legible series of OR conditions.
  # @return [Arel::Nodes::Grouping(Arel::Nodes::Or)]
  def arel_or_expressions(*expressions)
    expressions.flatten!

    return block_given? ? yield(expressions[0]) : expressions[0] if expressions.one?

    expressions.reduce do |grouping, expression|
      expression = yield expression if block_given?

      next grouping if expression.blank?

      if grouping.kind_of?(Arel::Nodes::Grouping)
        grouping.expr.or(expression)
      else
        # First expression
        grouping = yield grouping if block_given?

        grouping.or(expression)
      end
    end
  end

  # @param [String, Symbol, Arel::Attributes::Attribute, Arel::Nodes::SqlLiteral, Arel::Expresions, Arel::Node] attribute
  # @return [Arel::Attributes::Attribute]
  # @return [Arel::Nodes::SqlLiteral]
  # @return [Arel::Node]
  def arel_attrify(attribute)
    case attribute
    when Arel::Attributes::Attribute, Arel::Nodes::SqlLiteral, Arel::Expressions, Arel::Nodes::Node
      attribute
    when arel_column_matcher
      arel_table[attribute]
    when /\A[^.\s]+\.[^.\s]+/
      arel_literal attribute
    else
      raise TypeError, "Don't know how to turn #{attribute} into an Arel::Attribute"
    end
  end

  # @!scope private
  # @return [Regexp]
  def arel_column_matcher
    @arel_column_matcher ||= /\A#{Regexp.union(column_names)}\z/
  end
end
