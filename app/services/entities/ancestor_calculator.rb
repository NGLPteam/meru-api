# frozen_string_literal: true

module Entities
  # Calculate {EntityAncestor}s for a given descendant entity.
  #
  # @see Entities::CalculateAncestors
  class AncestorCalculator < Support::HookBased::Actor
    include QueryOperation
    include Dry::Initializer[undefined: false].define -> do
      param :descendant, Entities::Types::Entity, optional: true
    end

    BASE_QUERY = <<~SQL
    MERGE INTO entity_ancestors ea
    USING %<source>s eda ON (ea.entity_id = eda.entity_id AND ea.name = eda.name)
    WHEN MATCHED AND (
      ea.entity_type <> eda.entity_type
      OR
      ea.ancestor_type <> eda.ancestor_type
      OR
      ea.ancestor_id <> eda.ancestor_id
      OR
      ea.ancestor_schema_version_id <> eda.ancestor_schema_version_id
      OR
      ea.origin_depth <> eda.origin_depth
      OR
      ea.ancestor_depth <> eda.ancestor_depth
      OR
      ea.relative_depth <> eda.relative_depth
    ) THEN UPDATE SET
      entity_type = eda.entity_type,
      ancestor_type = eda.ancestor_type,
      ancestor_id = eda.ancestor_id,
      ancestor_schema_version_id = eda.ancestor_schema_version_id,
      origin_depth = eda.origin_depth,
      ancestor_depth = eda.ancestor_depth,
      relative_depth = eda.relative_depth,
      updated_at = CURRENT_TIMESTAMP
    WHEN NOT MATCHED THEN INSERT (
      entity_type,
      entity_id,
      ancestor_type,
      ancestor_id,
      ancestor_schema_version_id,
      name,
      origin_depth,
      ancestor_depth,
      relative_depth
    ) VALUES (
      eda.entity_type,
      eda.entity_id,
      eda.ancestor_type,
      eda.ancestor_id,
      eda.ancestor_schema_version_id,
      eda.name,
      eda.origin_depth,
      eda.ancestor_depth,
      eda.relative_depth
    );
    SQL

    # @return [Integer]
    attr_reader :changed

    # @return [String]
    attr_reader :query

    standard_execution!

    def call
      run_callbacks :execute do
        yield prepare!

        yield merge!
      end

      Success changed
    end

    wrapped_hook! def prepare
      @changed = 0

      @query = build_query

      super
    end

    wrapped_hook! def merge
      @changed = sql_update!(query)

      super
    end

    private

    def build_source
      if descendant
        "(#{EntityDerivedAncestor.where(entity_type: descendant.entity_type, entity_id: descendant.id).to_sql})"
      else
        "entity_derived_ancestors"
      end
    end

    def build_query
      source = build_source

      BASE_QUERY % { source: }
    end
  end
end
