# frozen_string_literal: true

module Schemas
  module Versions
    # Maintain the set of {SchemaVersionAssociation} records tied to a {SchemaVersion}.
    class MaintainAssociations
      include Dry::Monads[:do, :result]

      DEFAULT_PARENT_KINDS = %w[community collection item].freeze
      DEFAULT_CHILD_KINDS = %w[collection item].freeze

      # @param [SchemaVersion] schema_version
      # @return [Dry::Monads::Result]
      def call(schema_version)
        ids = yield upsert! schema_version

        yield prune! schema_version, ids

        yield update_cache! schema_version

        Success()
      end

      private

      # @param [ActiveRecord::Relation<SchemaVersionAssociation>] scope
      # @return [<String>]
      def enforce_child_kinds(scope)
        enforce_entity_kinds(scope, default: DEFAULT_CHILD_KINDS)
      end

      # @param [ActiveRecord::Relation<SchemaVersionAssociation>] scope
      # @return [<String>]
      def enforce_parent_kinds(scope)
        enforce_entity_kinds(scope, default: DEFAULT_PARENT_KINDS)
      end

      # @param [ActiveRecord::Relation<SchemaVersionAssociation>] scope
      # @param [<String>] default
      # @return [<String>]
      def enforce_entity_kinds(scope, default:)
        kinds = scope.reorder(kind: :asc).distinct.pluck(:kind)

        kinds.select { _1.in?(default) }.sort_by { default.index(_1) }.presence || default
      end

      # @param [SchemaVersion] source
      # @return [Dry::Monads::Success<String>] the upserted IDs
      def upsert!(source)
        rows = yield upsert_rows_for source

        return Success(Dry::Core::Constants::EMPTY_ARRAY) if rows.blank?

        result = SchemaVersionAssociation.upsert_all rows, unique_by: %i[source_id target_id name], returning: %i[id]

        ids = result.pluck("id")

        Success ids
      end

      # @param [SchemaVersion] source
      # @param [<String>] ids
      # @return [Dry::Monads::Success(Integer)]
      def prune!(source, ids)
        deleted = SchemaVersionAssociation.by_source(source).where.not(id: ids).delete_all

        Success deleted
      end

      # @param [SchemaVersion] source
      # @return [Dry::Monads::Result]
      def update_cache!(source)
        source.reload

        columns = {}

        parent_versions = source.enforced_parent_versions.reload
        child_versions = source.enforced_child_versions.reload

        columns[:enforces_parent] = source.parent_associations.exists?
        columns[:enforces_children] = source.child_associations.exists?
        columns[:enforced_parent_declarations] = parent_versions.pluck(:declaration)
        columns[:enforced_child_declarations] = child_versions.pluck(:declaration)
        columns[:enforced_parent_kinds] = enforce_parent_kinds(parent_versions)
        columns[:enforced_child_kinds] = enforce_child_kinds(child_versions)

        source.update_columns columns

        return Success()
      end

      # @param [SchemaVersion] source
      # @return [Dry::Monads::Success<Hash>]
      def upsert_rows_for(source)
        config = source.configuration

        mapping = {}

        mapping["parent"] = yield versions_for config.parents
        mapping["child"] = yield versions_for config.children
        mapping["submission"] = yield versions_for config.submissions

        rows = mapping.flat_map do |(name, targets)|
          targets.map do |target|
            { source_id: source.id, target_id: target.id, name:, updated_at: Time.current }
          end
        end

        Success rows
      end

      # @return [Dry::Monads::Success<SchemaVersion>]
      def versions_for(associations)
        matching = associations.flat_map(&:find_matching_versions).uniq

        Success matching
      end
    end
  end
end
