# frozen_string_literal: true

class Collection < ApplicationRecord
  include Accessible
  include Attachable
  include AutoIdentifier
  include Contributable
  include HarvestTarget
  include HasEntityVisibility
  include HasHarvestModificationStatus
  include HasSchemaDefinition
  include HasSystemSlug
  include HierarchicalEntity
  include ChildEntity
  include Permalinkable
  include ScopesForIdentifier

  drop_klass Templates::Drops::CollectionDrop

  has_closure_tree

  belongs_to :community, inverse_of: :collections

  has_many :attributions, -> { in_default_order }, class_name: "CollectionAttribution", dependent: :delete_all, inverse_of: :collection
  has_many :contributions, class_name: "CollectionContribution", dependent: :destroy, inverse_of: :collection

  has_many :contributors, through: :contributions

  has_many :items, dependent: :destroy, inverse_of: :collection

  has_one :entity_search_document, inverse_of: :collection, dependent: :delete

  has_many_readonly :related_collection_links, foreign_key: :source_id, inverse_of: :source
  has_many_readonly :incoming_collection_links, foreign_key: :target_id, class_name: "RelatedCollectionLink", inverse_of: :target
  has_many_readonly :related_collections, through: :related_collection_links, source: :target

  validates :identifier, :title, presence: true
  validates :identifier, uniqueness: { scope: %i[community_id parent_id] }

  # @return [:collection]
  def entity_kind
    :collection
  end

  # @return [Community]
  def hierarchical_parent
    community
  end

  def hierarchical_children
    items
  end

  # @return [Collection, nil]
  def largest_child_collection
    children.preload(:entity_descendants).max_by { |c| c.entity_descendants.size }
  end

  # @see Collections::Purge
  # @see Collections::Purger
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def purge(...)
    call_operation("collections.purge", self, ...)
  end
end
