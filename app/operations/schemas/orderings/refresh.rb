# frozen_string_literal: true

module Schemas
  module Orderings
    # Refresh an {Ordering} and calculate the {OrderingEntry entries} that should appear within.
    #
    # Once that finishes, it will purge any entries that should no longer be considered part of
    # the ordering.
    class Refresh
      include Dry::Monads[:do, :result, :try]
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
      INSERT INTO ordering_entries (ordering_id, entity_id, entity_type, position, inverse_position, link_operator, auth_path, scope, relative_depth, order_props, tree_depth, tree_parent_id, tree_parent_type)
      SQL

      SUFFIX = <<~SQL.squish
      ON CONFLICT (ordering_id, entity_type, entity_id) DO UPDATE SET
        stale_at = NULL,
        position = EXCLUDED.position,
        inverse_position = EXCLUDED.inverse_position,
        link_operator = EXCLUDED.link_operator,
        auth_path = EXCLUDED.auth_path,
        scope = EXCLUDED.scope,
        relative_depth = EXCLUDED.relative_depth,
        order_props = EXCLUDED.order_props,
        tree_depth = EXCLUDED.tree_depth,
        tree_parent_id = EXCLUDED.tree_parent_id,
        tree_parent_type = EXCLUDED.tree_parent_type,
        updated_at = CASE WHEN
          ordering_entries.position IS DISTINCT FROM EXCLUDED.position
          OR
          ordering_entries.inverse_position IS DISTINCT FROM EXCLUDED.inverse_position
          OR
          ordering_entries.link_operator IS DISTINCT FROM EXCLUDED.link_operator
          OR
          ordering_entries.auth_path IS DISTINCT FROM EXCLUDED.auth_path
          OR
          ordering_entries.scope IS DISTINCT FROM EXCLUDED.scope
          OR
          ordering_entries.relative_depth IS DISTINCT FROM EXCLUDED.relative_depth
          OR
          ordering_entries.order_props IS DISTINCT FROM EXCLUDED.order_props
          OR
          ordering_entries.tree_depth IS DISTINCT FROM EXCLUDED.tree_depth
          OR
          ordering_entries.tree_parent_id IS DISTINCT FROM EXCLUDED.tree_parent_id
          OR
          ordering_entries.tree_parent_type IS DISTINCT FROM EXCLUDED.tree_parent_type
          THEN CURRENT_TIMESTAMP
          ELSE
          ordering_entries.updated_at
          END
      RETURNING ordering_entries.updated_at = CURRENT_TIMESTAMP AS updated
      SQL

      ANCESTOR_LINK_QUERY = <<~SQL
      INSERT INTO ordering_entry_ancestor_links (ordering_id, child_id, ancestor_id, inverse_depth)
      SELECT oe.ordering_id, oe.id AS child_id, anc.id AS ancestor_id, oe.tree_depth - anc.tree_depth AS inverse_depth
      FROM ordering_entries oe
      INNER JOIN ordering_entries anc ON oe.ordering_id = anc.ordering_id AND oe.auth_path <@ anc.auth_path AND anc.tree_depth < oe.tree_depth
      WHERE oe.tree_depth > 1 AND oe.ordering_id = %s
      ON CONFLICT (ordering_id, child_id, inverse_depth) DO UPDATE SET
        ancestor_id = EXCLUDED.ancestor_id,
        updated_at = CASE WHEN ordering_entry_ancestor_links.ancestor_id IS DISTINCT FROM EXCLUDED.ancestor_id THEN CURRENT_TIMESTAMP ELSE ordering_entry_ancestor_links.updated_at END
      RETURNING ordering_entry_ancestor_links.updated_at = CURRENT_TIMESTAMP AS updated
      SQL

      SIBLING_LINK_QUERY = <<~SQL
      INSERT INTO ordering_entry_sibling_links (ordering_id, sibling_id, prev_id, next_id)
      SELECT ordering_id, id AS sibling_id, lag(id) OVER w AS prev_id, lead(id) OVER w AS next_id
      FROM ordering_entries
      WHERE ordering_id = %s
      WINDOW w AS (PARTITION BY ordering_id ORDER BY position ASC)
      ON CONFLICT (ordering_id, sibling_id) DO UPDATE SET
        prev_id = EXCLUDED.prev_id,
        next_id = EXCLUDED.next_id,
        updated_at = CASE WHEN
          EXCLUDED.prev_id IS DISTINCT FROM ordering_entry_sibling_links.prev_id
          OR
          EXCLUDED.next_id IS DISTINCT FROM ordering_entry_sibling_links.next_id
          THEN CURRENT_TIMESTAMP
          ELSE ordering_entry_sibling_links.updated_at END
      RETURNING ordering_entry_sibling_links.updated_at = CURRENT_TIMESTAMP AS updated
      SQL

      # @param [Ordering] ordering
      # @return [Dry::Monads::Result]
      def call(ordering)
        yield lock! ordering

        yield mark_stale! ordering

        updated_count = yield update! ordering

        deleted_count = OrderingEntry.delete_stale_for(ordering)

        updated_ancestor_count = yield update_ancestors! ordering

        updated_sibling_count = yield update_siblings! ordering

        response = {
          deleted_count:,
          updated_count:,
          updated_ancestor_count:,
          updated_sibling_count:,
        }

        yield ordering.calculate_stats

        Success response
      end

      private

      # @!group Steps

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(void)]
      def lock!(ordering)
        query = with_quoted_id_for ordering, LOCK_QUERY

        Try do
          sql_select! query
        end
      end

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(void)]
      def mark_stale!(ordering)
        query = with_quoted_id_for ordering, <<~SQL
        UPDATE ordering_entries SET stale_at = CURRENT_TIMESTAMP
        WHERE ordering_id = %s
        SQL

        Try do
          sql_update! query
        end
      end

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(Integer)]
      def update!(ordering)
        select_query = build_select_statement ordering

        Try do
          result = sql_insert! PREFIX, select_query, SUFFIX

          result.count { |row| row["updated"] }
        end
      end

      # @param [Ordering] ordering
      # @return [Dry::Monads::Success(Integer)]
      def update_ancestors!(ordering)
        update_query = with_quoted_id_for ordering, ANCESTOR_LINK_QUERY

        Try do
          result = sql_insert! update_query

          result.count { |row| row["updated"] }
        end
      end

      def update_siblings!(ordering)
        update_query = with_quoted_id_for ordering, SIBLING_LINK_QUERY

        Try do
          result = sql_insert! update_query

          result.count { |row| row["updated"] }
        end
      end

      # @!endgroup

      # @see OrderingEntryCandidate.query_for
      # @param [Ordering] ordering
      # @return [String]
      def build_select_statement(ordering)
        OrderingEntryCandidate.query_for(ordering).to_sql
      end
    end
  end
end
