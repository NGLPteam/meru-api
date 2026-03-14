# frozen_string_literal: true

# A view that wraps around {Entity} and {SchemaVersion} to present values
# for sorting and upserting directly into {OrderingEntry}. Individual
# instances of this model are never used.
#
# @see Schemas::Orderings::Refresh
# rubocop:disable Metrics/AbcSize
class OrderingEntryCandidate < ApplicationRecord
  include GenericInaccessible
  include View

  include EntityAdjacent

  belongs_to :entity, polymorphic: true
  belongs_to :schema_version

  # Calculate one-time stats that are used for {SCORED_CANDIDATES_QUERY}.
  TREE_STATS_QUERY = <<~SQL
  SELECT
    text2ltree(%1$s) AS parent_path,
    COUNT(*) FILTER (WHERE auth_path <> %1$s) AS total_descendants,
    MAX(nlevel(auth_path) - nlevel(text2ltree(%1$s))) AS max_depth
  FROM ordering_entry_candidates
  WHERE
    auth_path <@ text2ltree(%1$s)
  SQL

  # Recalculate ordering positions based on relative depth and
  # ancestral scores.
  SCORED_CANDIDATES_QUERY = <<~SQL
  WITH pseudo_tree AS (
    SELECT fc.entity_id, fc.entity_type,
      anc.auth_path,
      anc.position AS position,
      anc.inverse_position AS inverse_position
      FROM flat_candidates fc
      INNER JOIN flat_candidates AS anc ON
        anc.auth_path @> fc.auth_path
  ), hierarchies AS (
    SELECT entity_id, entity_type, COUNT(DISTINCT auth_path) AS tree_depth
    FROM pseudo_tree
    GROUP BY 1, 2
  )
  SELECT pt.entity_id, pt.entity_type,
    SUM(
      (1 + pt.position)
      *
      (
        stats.total_descendants
        ^
        (
          stats.max_depth + 1 - hier.tree_depth
        )
      )
    )::decimal AS position,
    SUM(
      (1 + pt.inverse_position)
      *
      (
        stats.total_descendants
        ^
        (
          stats.max_depth + 1 - hier.tree_depth
        )
      )
    )::decimal AS inverse_position,
    hier.tree_depth
  FROM pseudo_tree AS pt
  CROSS JOIN stats
  INNER JOIN hierarchies hier USING (entity_id, entity_type)
  GROUP BY entity_id, entity_type, hier.tree_depth
  SQL

  # For finalizing the tree-ordered {.query_for} by combining the recalculated
  # positions in {SCORED_CANDIDATES_QUERY} with the otherwise static values
  # in the original generated query.
  REMAPPED_CANDIDATES_QUERY = <<~SQL
  SELECT
    fc.ordering_id,
    entity_id,
    entity_type,
    row_number() OVER (ORDER BY COALESCE(td.position, sc.position) ASC, td.tree_depth ASC NULLS FIRST, sc.position ASC) AS position,
    row_number() OVER (ORDER BY COALESCE(td.position, sc.position) ASC, td.tree_depth DESC NULLS FIRST, sc.inverse_position ASC) AS inverse_position,
    fc.link_operator,
    fc.auth_path,
    fc.scope,
    fc.relative_depth,
    fc.order_props,
    sc.tree_depth,
    td.tree_parent_id,
    td.tree_parent_type
  FROM flat_candidates AS fc
  INNER JOIN scored_candidates AS sc USING (entity_id, entity_type)
  LEFT JOIN LATERAL (
    SELECT DISTINCT ON (p.entity_id, p.entity_type)
      p.entity_id AS tree_parent_id, p.entity_type AS tree_parent_type, p.position, p.inverse_position, p.tree_depth
    FROM scored_candidates AS p
    INNER JOIN flat_candidates x ON p.entity_id = x.entity_id AND p.entity_type = x.entity_type
    WHERE
      fc.relative_depth > 1
      AND
      x.auth_path @> fc.auth_path
      AND
      p.tree_depth < sc.tree_depth
    ORDER BY p.entity_id, p.entity_type, p.tree_depth DESC
    LIMIT 1
  ) td ON fc.relative_depth > 1
  SQL

  class << self
    # Build a SQL query that orders a subset of {OrderingEntryCandidate} by whatever
    # an {Ordering} is {Schemas::Orderings::Definition is looking for}.
    #
    # @param [Ordering] ordering
    # @return [ActiveRecord::Relation<OrderingEntryCandidate>]
    def query_for(ordering)
      base_query = build_projection_and_joins_for(ordering).
        with_schema_selector_for(ordering).
        with_child_selector_for(ordering).
        with_link_selector_for(ordering)

      return base_query unless ordering.tree_mode?

      entity = ordering.entity

      stats_query = TREE_STATS_QUERY % connection.quote(entity.auth_path)

      all.with(
        stats: stats_query,
        flat_candidates: base_query,
        scored_candidates: SCORED_CANDIDATES_QUERY,
        remapped_candidates: REMAPPED_CANDIDATES_QUERY
      ).select(
        "ordering_id", "entity_id", "entity_type", "position", "inverse_position", "link_operator", "auth_path", "scope", "relative_depth",
        "order_props", "tree_depth", "tree_parent_id", "tree_parent_type"
      ).from("remapped_candidates").order(position: :asc)
    end

    # @api private
    # @param [Ordering] ordering
    # @return [ActiveRecord::Relation<OrderingEntryCandidate>]
    def with_child_selector_for(ordering)
      selection = ordering.definition.select

      auth_path = arel_table[:auth_path]

      lqueries = selection.build_auth_query_for(ordering.entity.auth_path)

      expr = arel_ltree_matches_one_or_any(auth_path, lqueries)

      where(expr)
    end

    # @api private
    # @param [Ordering] ordering
    # @return [ActiveRecord::Relation<OrderingEntryCandidate>]
    def with_link_selector_for(ordering)
      links = ordering.definition.select.links

      if links.none?
        where(link_operator: nil)
      elsif links.any? && !links.all?
        where(link_operator: links.selector)
      else
        all
      end
    end

    # @api private
    # @param [Ordering] ordering
    # @return [ActiveRecord::Relation<OrderingEntryCandidate>]
    def with_schema_selector_for(ordering)
      allowed_schema_versions = ordering.definition.filter.allowed_schema_versions

      if allowed_schema_versions.present?
        where(schema_version: allowed_schema_versions)
      else
        all
      end
    end

    private

    # Starts off the query for {.query_for}
    # @param [Ordering] ordering
    # @return [ActiveRecord::Relation<OrderingEntryCandidate>]
    def build_projection_and_joins_for(ordering)
      entity = ordering.entity

      compiled = ordering.compile_ordering_expression

      ordering_id_expr = arel_cast(arel_quote(ordering.id), "uuid").as("ordering_id")

      order_props_expr = arel_order_props_expr_for compiled.props

      default_position_expr = arel_windowed_position_for compiled.default_orderings

      inverse_position_expr = arel_windowed_position_for compiled.inverse_orderings

      relative_depth_expr = arel_relative_depth_for(entity)

      query = select(
        ordering_id_expr,
        arel_table[:hierarchical_id].as("entity_id"),
        arel_table[:hierarchical_type].as("entity_type"),
        default_position_expr.as("position"),
        inverse_position_expr.as("inverse_position"),
        arel_table[:link_operator],
        arel_table[:auth_path],
        arel_table[:scope],
        relative_depth_expr.as("relative_depth"),
        order_props_expr.as("order_props"),
        arel_literal(%[NULL::bigint]).as("tree_depth"),
        arel_literal(%[NULL::uuid]).as("tree_parent_id"),
        arel_literal(%[NULL::text]).as("tree_parent_type")
      ).distinct_on(:hierarchical_type, :hierarchical_id)

      query.joins!(*compiled.joins.values) if compiled.joins.any?

      query.order! arel_table[:hierarchical_type].asc, arel_table[:hierarchical_id].asc, arel_table[:link_operator].asc.nulls_last

      return query
    end

    # @param [{ String => Arel::Nodes::Node }]
    def arel_order_props_expr_for(props)
      args = props.each_pair.flat_map do |(path, expr)|
        [arel_quote(path), expr]
      end

      arel_named_fn("jsonb_build_object", *args)
    end

    # @param [HasSchemaDefinition] entity
    # @return [Arel::Nodes::Subtraction(Arel::Attribute, Arel::Nodes::Quoted)]
    def arel_relative_depth_for(entity)
      hierarchical_depth = [entity.hierarchical_depth, 1].compact.max

      arel_table[:entity_depth] - arel_quote(hierarchical_depth)
    end

    # @param [<Arel::Nodes::Ordering>] order_statements
    # @return [Arel::Nodes::Over]
    def arel_windowed_position_for(order_statements)
      window = Arel::Nodes::Window.new.order(*order_statements)

      arel_named_fn("row_number").over(window)
    end
  end
end
# rubocop:enable Metrics/AbcSize
