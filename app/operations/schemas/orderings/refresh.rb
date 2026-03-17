# frozen_string_literal: true

module Schemas
  module Orderings
    # Refresh an {Ordering} and calculate the {OrderingEntry entries} that should appear within.
    #
    # Once that finishes, it will purge any entries that should no longer be considered part of
    # the ordering.
    class Refresh
      include Dry::Monads[:result]
      include QueryOperation

      prepend TransactionalCall

      deadlock_retry_count 5

      start_new_transaction!

      LOCK_QUERY = <<~SQL
      SELECT * FROM ordering_entries
      WHERE ordering_id = %s
      FOR UPDATE;
      SQL

      PREFIX = <<~SQL.squish
      WITH candidate_entries AS (
      SQL

      SUFFIX = <<~SQL.squish
      )
      MERGE INTO ordering_entries AS target
      USING candidate_entries
        ON target.ordering_id = candidate_entries.ordering_id
        AND target.entity_type = candidate_entries.entity_type
        AND target.entity_id = candidate_entries.entity_id
      WHEN MATCHED
        AND (
          target.position <> candidate_entries.position
          OR
          target.inverse_position <> candidate_entries.inverse_position
          OR
          target.link_operator IS DISTINCT FROM candidate_entries.link_operator
          OR
          target.auth_path <> candidate_entries.auth_path
          OR
          target.scope <> candidate_entries.scope
          OR
          target.relative_depth <> candidate_entries.relative_depth
          OR
          target.order_props <> candidate_entries.order_props
          OR
          target.tree_depth IS DISTINCT FROM candidate_entries.tree_depth
          OR
          target.tree_parent_id IS DISTINCT FROM candidate_entries.tree_parent_id
          OR
          target.tree_parent_type IS DISTINCT FROM candidate_entries.tree_parent_type
        )
      THEN UPDATE SET
        position = candidate_entries.position,
        inverse_position = candidate_entries.inverse_position,
        link_operator = candidate_entries.link_operator,
        auth_path = candidate_entries.auth_path,
        scope = candidate_entries.scope,
        relative_depth = candidate_entries.relative_depth,
        order_props = candidate_entries.order_props,
        tree_depth = candidate_entries.tree_depth,
        tree_parent_id = candidate_entries.tree_parent_id,
        tree_parent_type = candidate_entries.tree_parent_type,
        updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED THEN INSERT
        (ordering_id, entity_id, entity_type, position, inverse_position, link_operator, auth_path, scope, relative_depth, order_props, tree_depth, tree_parent_id, tree_parent_type)
        VALUES (candidate_entries.ordering_id, candidate_entries.entity_id, candidate_entries.entity_type, candidate_entries.position, candidate_entries.inverse_position, candidate_entries.link_operator, candidate_entries.auth_path, candidate_entries.scope, candidate_entries.relative_depth, candidate_entries.order_props, candidate_entries.tree_depth, candidate_entries.tree_parent_id, candidate_entries.tree_parent_type)
      WHEN NOT MATCHED BY SOURCE AND target.ordering_id = %1$s THEN DELETE
      SQL

      ANCESTOR_LINK_QUERY = <<~SQL
      WITH ancestor_entries AS (
        SELECT oe.ordering_id, oe.id AS child_id, anc.id AS ancestor_id, oe.tree_depth - anc.tree_depth AS inverse_depth
        FROM ordering_entries oe
        INNER JOIN ordering_entries anc ON oe.ordering_id = anc.ordering_id AND oe.auth_path <@ anc.auth_path AND anc.tree_depth < oe.tree_depth
        WHERE oe.tree_depth > 1 AND oe.ordering_id = %1$s
      )
      MERGE INTO ordering_entry_ancestor_links AS target
      USING ancestor_entries AS source
      ON target.ordering_id = source.ordering_id AND target.child_id = source.child_id AND target.inverse_depth = source.inverse_depth
      WHEN MATCHED AND target.ancestor_id <> source.ancestor_id THEN
        UPDATE SET ancestor_id = source.ancestor_id, updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED THEN
        INSERT (ordering_id, child_id, ancestor_id, inverse_depth)
        VALUES (source.ordering_id, source.child_id, source.ancestor_id, source.inverse_depth)
      WHEN NOT MATCHED BY SOURCE AND target.ordering_id = %1$s THEN DELETE
      SQL

      SIBLING_LINK_QUERY = <<~SQL
      WITH sibling_entries AS (
        SELECT ordering_id, id AS sibling_id, lag(id) OVER w AS prev_id, lead(id) OVER w AS next_id
        FROM ordering_entries
        WHERE ordering_id = %1$s
        WINDOW w AS (PARTITION BY ordering_id ORDER BY position ASC)
      )
      MERGE INTO ordering_entry_sibling_links AS target
      USING sibling_entries AS source
      ON target.ordering_id = source.ordering_id AND target.sibling_id = source.sibling_id
      WHEN MATCHED AND (
        target.prev_id IS DISTINCT FROM source.prev_id
        OR
        target.next_id IS DISTINCT FROM source.next_id
      ) THEN
        UPDATE SET prev_id = source.prev_id, next_id = source.next_id, updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED THEN
        INSERT (ordering_id, sibling_id, prev_id, next_id)
        VALUES (source.ordering_id, source.sibling_id, source.prev_id, source.next_id)
      WHEN NOT MATCHED BY SOURCE AND target.ordering_id = %1$s THEN DELETE
      SQL

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(void)]
      def call(ordering)
        lock! ordering

        update! ordering

        update_ancestors! ordering

        update_siblings! ordering

        ordering.calculate_stats!

        Success()
      end

      private

      # @!group Steps

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(void)]
      def lock!(ordering)
        query = with_quoted_id_for ordering, LOCK_QUERY

        sql_select! query
      end

      # @param [Ordering] ordering
      # @return [void]
      def update!(ordering)
        select_query = build_select_statement ordering

        suffix = with_quoted_id_for ordering, SUFFIX

        sql_insert! PREFIX, select_query, suffix
      end

      # @param [Ordering] ordering
      # @return [void]
      def update_ancestors!(ordering)
        update_query = with_quoted_id_for ordering, ANCESTOR_LINK_QUERY

        sql_insert! update_query
      end

      # @param [Ordering] ordering
      # @return [void]
      def update_siblings!(ordering)
        update_query = with_quoted_id_for ordering, SIBLING_LINK_QUERY

        sql_insert! update_query
      end

      # @!endgroup Steps

      # @see OrderingEntryCandidate.query_for
      # @param [Ordering] ordering
      # @return [String]
      def build_select_statement(ordering)
        OrderingEntryCandidate.query_for(ordering).to_sql
      end
    end
  end
end
