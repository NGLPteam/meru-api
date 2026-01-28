# frozen_string_literal: true

module EntityVisibilities
  # Ensure {EntityVisibility} is populated for each extant {Entity}.
  class Populate
    include Dry::Monads[:result]
    include QueryOperation

    QUERY = <<~SQL
    MERGE INTO entity_visibilities ev
    USING (
      SELECT DISTINCT entity_type, entity_id
      FROM entities
      WHERE scope IN ('collections', 'items')
    ) AS src ON (ev.entity_type = src.entity_type AND ev.entity_id = src.entity_id)
    WHEN NOT MATCHED THEN INSERT (entity_type, entity_id)
    VALUES (src.entity_type, src.entity_id);
    SQL

    # @return [Dry::Monads::Success]
    def call
      sql_insert! QUERY

      Success()
    end
  end
end
