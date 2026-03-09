# frozen_string_literal: true

class HierarchicalSchemaVersionRank < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[entity_type entity_id schema_definition_id schema_version_id]

  HIERARCHICAL_TUPLE = %i[entity_type entity_id schema_definition_id].freeze

  belongs_to :entity, polymorphic: true, inverse_of: :hierarchical_schema_version_ranks

  belongs_to :hierarchical_schema_rank,
    foreign_key: HIERARCHICAL_TUPLE,
    inverse_of: :hierarchical_schema_version_ranks

  belongs_to :schema_definition

  belongs_to :schema_version

  scope :with_details, -> { preload(:schema_definition, schema_version: :schema_definition) }
  scope :in_default_order, -> { reorder(schema_rank: :asc, schema_count: :desc) }
  scope :for_association, -> { with_details.in_default_order }

  delegate :kind, :identifier, :name, :namespace, to: :schema_definition
  delegate :declaration, to: :schema_version
  delegate :number, to: :schema_version, prefix: :version

  def schema_slug
    schema_version.system_slug
  end
end
