# frozen_string_literal: true

class EntitySearchDocument < ApplicationRecord
  include EntityAdjacent
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include PgSearch::Model
  include TimestampScopes

  CONTEXTUAL_TUPLE = %i[hierarchical_type hierarchical_id].freeze

  ENTITY_TUPLE = %i[entity_type entity_id].freeze

  has_many_readonly :synchronized_entities, class_name: "Entity",
    inverse_of: :entity_search_document,
    foreign_key: CONTEXTUAL_TUPLE,
    primary_key: ENTITY_TUPLE

  belongs_to :community, inverse_of: :entity_search_document
  belongs_to :collection, inverse_of: :entity_search_document
  belongs_to :item, inverse_of: :entity_search_document

  pg_search_scope :search_by_prefix,
    against: %i[title],
    ignoring: :accents,
    using: {
      tsearch: {
        prefix: true
      }
    }

  pg_search_scope :search_by_query,
    against: %i[title author_names schematic_texts],
    ignoring: :accents,
    using: {
      tsearch: {
        tsvector_column: "document",
        websearch: true,
      }
    }
end
