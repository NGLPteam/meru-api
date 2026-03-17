# frozen_string_literal: true

module Schemas
  module Versions
    # Extract {SchemaVersionProperty} records for a given {SchemaVersion}.
    #
    # {SchemaDefinitionProperty} records are derived from this and get
    # refreshed as part of {System::Checker}.
    class ExtractProperties
      include Dry::Monads[:result]
      include QueryOperation

      MERGE_QUERY = <<~SQL
      WITH version_props AS (
        %{values_list}
      )
      MERGE INTO schema_version_properties AS target
      USING version_props AS source
        ON target.schema_version_id = source.schema_version_id
        AND target.path = source.path
      WHEN MATCHED THEN UPDATE SET
        schema_definition_id = source.schema_definition_id,
        position = source.position,
        "array" = source.array,
        nested = source.nested,
        orderable = source.orderable,
        "required" = source.required,
        kind = source.kind,
        "type" = source.type,
        label = source.label,
        extract_path = source.extract_path,
        metadata = source.metadata,
        "function" = source.function,
        searchable = source.searchable,
        updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED THEN INSERT (
        schema_version_id,
        schema_definition_id,
        position,
        "array",
        nested,
        orderable,
        "required",
        kind,
        "type",
        "path",
        label,
        extract_path,
        metadata,
        "function",
        searchable
      ) VALUES (
        source.schema_version_id,
        source.schema_definition_id,
        source.position,
        source.array,
        source.nested,
        source.orderable,
        source.required,
        source.kind,
        source.type,
        source.path,
        source.label,
        source.extract_path,
        source.metadata,
        source.function,
        source.searchable
      )
      WHEN NOT MATCHED BY SOURCE AND target.schema_version_id = %{schema_version_id} THEN DELETE
      SQL

      # @param [SchemaVersion] schema_version
      # @return [Dry::Monads::Success(Boolean)] the boolean signifies whether there were any
      #   properties to upsert.
      def call(schema_version)
        rows = schema_version.to_version_properties

        if rows.empty?
          # If there are no properties, we can skip the upsert and just delete any existing ones
          schema_version.schema_version_properties.delete_all

          return Success(false)
        end

        values_list = ::Utility::ValueSelectQuery.new(
          rows,
          casts: {
            extract_path: "text[]",
            metadata: "jsonb",
          },
          model_class: SchemaVersionProperty
        ).to_sql

        schema_version_id = schema_version.quoted_id

        query = MERGE_QUERY % { values_list:, schema_version_id: }

        sql_insert! query

        Success(true)
      end
    end
  end
end
