# frozen_string_literal: true

module Entities
  # @see Schemas::Instances::ExtractComposedTexts
  class CalculateComposedTexts
    include Dry::Monads[:do, :result]
    include QueryOperation

    PREFIX = <<~SQL
    WITH aggregated_texts AS (
      SELECT entity_type, entity_id, tsvector_agg(document) AS document
      FROM schematic_texts
    SQL

    SUFFIX = <<~SQL
      GROUP BY 1, 2
    )
    MERGE INTO entity_composed_texts AS target
    USING aggregated_texts AS source
     ON target.entity_id = source.entity_id AND target.entity_type = source.entity_type
     WHEN MATCHED AND target.document <> source.document THEN
       UPDATE SET document = source.document, updated_at = CURRENT_TIMESTAMP
     WHEN NOT MATCHED THEN
       INSERT (entity_type, entity_id, document)
       VALUES (source.entity_type, source.entity_id, source.document)
    ;
    SQL

    # @param [HierarchicalEntity] entity
    # @return [Dry::Monads::Success(Integer)]
    def call(entity: nil)
      inserted = sql_insert! PREFIX, generate_infix_for(entity:), SUFFIX

      Success(inserted)
    end

    private

    # Generate an infix to possibly fit between {PREFIX} and {SUFFIX}.
    #
    # @param [String] auth_path
    # @param [Boolean] stale
    # @return [String]
    def generate_infix_for(entity: nil)
      with_quoted_id_for(entity, <<~SQL)
      WHERE entity_id = %1$s
      SQL
    end
  end
end
