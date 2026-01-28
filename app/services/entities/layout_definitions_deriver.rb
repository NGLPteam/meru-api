# frozen_string_literal: true

module Entities
  # Calculate which {LayoutDefinition}s should apply to a specific {HierarchicalEntity},
  # based on {LayoutDefinitionHierarchy}.
  #
  # This is used for a number of tasks.
  #
  # @see Entities::DeriveLayoutDefinitions
  class LayoutDefinitionsDeriver < Support::HookBased::Actor
    include QueryOperation
    include Dry::Initializer[undefined: false].define -> do
      option :entity, Entities::Types::Entity.optional, optional: true
    end

    PREFIX = <<~SQL.strip_heredoc
    WITH derivations AS NOT MATERIALIZED (
      SELECT DISTINCT ON (ent.entity_id, ldh.layout_kind)
        ent.schema_version_id,
        ent.entity_type,
        ent.entity_id,
        ldh.layout_definition_type,
        ldh.layout_definition_id,
        ldh.kind AS layout_definition_kind,
        ldh.layout_kind
        FROM entities ent
        INNER JOIN layout_definition_hierarchies ldh USING (schema_version_id)
        WHERE ent.auth_path <@ ldh.auth_path AND ent.real
    SQL

    SUFFIX = <<~SQL.strip_heredoc
        ORDER BY ent.entity_id, ldh.layout_kind, ldh.depth DESC
    )
    MERGE INTO entity_derived_layout_definitions edld
    USING derivations ON (edld.entity_id = derivations.entity_id AND edld.layout_kind = derivations.layout_kind)
    WHEN MATCHED AND (
      edld.schema_version_id <> derivations.schema_version_id
      OR
      edld.entity_type <> derivations.entity_type
      OR
      edld.layout_definition_type <> derivations.layout_definition_type
      OR
      edld.layout_definition_id <> derivations.layout_definition_id
    ) THEN UPDATE SET
      schema_version_id = derivations.schema_version_id,
      entity_type = derivations.entity_type,
      layout_definition_type = derivations.layout_definition_type,
      layout_definition_id = derivations.layout_definition_id,
      updated_at = CURRENT_TIMESTAMP
    WHEN NOT MATCHED THEN INSERT (
      schema_version_id,
      entity_type,
      entity_id,
      layout_definition_type,
      layout_definition_id,
      layout_kind
    ) VALUES (
      derivations.schema_version_id,
      derivations.entity_type,
      derivations.entity_id,
      derivations.layout_definition_type,
      derivations.layout_definition_id,
      derivations.layout_kind
    );
    SQL

    standard_execution!

    # @return [String, nil]
    attr_reader :entity_constraint

    # @return [Integer]
    attr_reader :derived

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield prepare!

        yield derive!
      end

      Success derived
    end

    wrapped_hook! def prepare
      @derived = 0

      @entity_constraint = with_quoted_id_for(entity, <<~SQL)
      AND ent.entity_id = %1$s
      SQL

      super
    end

    wrapped_hook! def derive
      @derived = sql_update!(PREFIX, entity_constraint, SUFFIX)

      super
    end
  end
end
