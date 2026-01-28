# frozen_string_literal: true

module Entities
  # Prune the {EntityHierarchy} table in case a lifecycle method neglects to delete it.
  class AuditHierarchies
    include Dry::Monads[:result]
    include QueryOperation

    # Check polymorphic associations for removed entities.
    CLEANUP = <<~SQL
    WITH sources AS (
      SELECT 'Community' AS type, id FROM communities
      UNION ALL
      SELECT 'Collection' AS type, id FROM collections
      UNION ALL
      SELECT 'EntityLink' AS type, id FROM entity_links
      UNION ALL
      SELECT 'Item' AS type, id FROM items
    )
    DELETE
    FROM entity_hierarchies
    WHERE
      (ancestor_type, ancestor_id) NOT IN (SELECT type, id FROM sources)
      OR
      (descendant_type, descendant_id) NOT IN (SELECT type, id FROM sources)
      OR
      (hierarchical_type, hierarchical_id) NOT IN (SELECT type, id FROM sources)
    ;
    SQL

    # @return [Dry::Monads::Success(Integer)]
    def call
      Success sql_delete! CLEANUP
    end
  end
end
