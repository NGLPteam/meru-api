# frozen_string_literal: true

class HierarchicalSchemaRank < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[entity_type entity_id schema_definition_id]

  belongs_to_readonly :entity, polymorphic: true, inverse_of: :hierarchical_schema_ranks

  has_many_readonly :hierarchical_schema_version_ranks, -> { for_association },
    foreign_key: primary_key,
    inverse_of: :hierarchical_schema_rank

  belongs_to_readonly :schema_definition

  scope :in_default_order, -> { reorder(schema_rank: :asc, schema_count: :desc) }
  scope :for_association, -> { in_default_order }

  delegate :declaration, :kind, :identifier, :name, :namespace, to: :schema_definition

  def schema_slug
    schema_definition.system_slug
  end
end
