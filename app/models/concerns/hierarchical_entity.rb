# frozen_string_literal: true

# The core interface for defining hierarchical entities
#
# Hierarchical entities are those that exist within a hierarchy,
# such as {Community}, {Collection}, and {Item}.
#
# This concern provides the shared behavior for all hierarchical entities,
# including ancestor/descendant relationships, contextual permissions,
# entity linking, ordering, and templating.
#
# For historical reasons, some code may refer to a `SchemaInstance`, this
# is synonymous with a `HierarchicalEntity`.
#
# @abstract
module HierarchicalEntity
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include AssociationHelpers
  include CacheWarmable
  include ChecksContextualPermissions
  include ConfiguresContributionRole
  include EntityTemplating
  include HasHarvestLookupHelpers
  include HasSystemSlug
  include Liquifies
  include ManualListSource
  include ManualListTarget
  include ModifiedByAdmin
  include Renderable
  include SyncsEntities
  include TimestampScopes
  include ScopesForEntityComposedText

  included do
    include ImageUploader::Attachment.new(:hero_image)
    include ImageUploader::Attachment.new(:thumbnail)

    contextual_permission_primary_key :id

    has_many :announcements, as: :entity, dependent: :destroy

    has_many :authorizing_entities, as: :hierarchical, inverse_of: :hierarchical, dependent: :delete_all

    has_many :hierarchical_entity_entries, as: :hierarchical, dependent: :destroy,
      class_name: "Entity"

    has_many :named_ancestors, -> { in_default_order.preload(:ancestor) }, class_name: "EntityAncestor", as: :entity, inverse_of: :entity, dependent: :delete_all
    has_many :named_descendants, class_name: "EntityAncestor", as: :ancestor, inverse_of: :ancestor, dependent: :delete_all

    has_many :entity_links, -> { preload(:target) }, as: :source, dependent: :destroy, inverse_of: :source
    has_many :incoming_links, -> { preload(:source) }, as: :target, class_name: "EntityLink", dependent: :destroy, inverse_of: :target

    has_one :entity_composed_text, as: :entity, dependent: :destroy

    has_many_readonly :contextual_permissions, as: :hierarchical
    has_many_readonly :contextual_single_permissions, as: :hierarchical

    has_many_readonly :assigned_users, through: :contextual_permissions, source: :user

    has_many_readonly :entity_breadcrumbs, -> { preload(:crumb).order(depth: :asc) }, as: :entity
    has_many_readonly :entity_breadcrumb_entries, class_name: "EntityBreadcrumb", as: :crumb

    has_many_readonly :entity_derived_ancestors, -> { in_default_order.preload(:ancestor) }, as: :entity, inverse_of: :entity
    has_many_readonly :entity_derived_descendants, as: :descendant, inverse_of: :descendant, class_name: "EntityDerivedAncestor"

    has_many_readonly :entity_descendants, as: :parent, inverse_of: :parent

    has_many_readonly :entity_inherited_orderings, as: :entity, inverse_of: :entity

    has_many_readonly :hierarchical_schema_ranks, -> { for_association }, as: :entity
    has_many_readonly :hierarchical_schema_version_ranks, -> { for_association }, as: :entity

    has_many_readonly :link_target_candidates, as: :source

    has_many :entity_hierarchies, as: :ancestor, dependent: :delete_all
    has_many :entity_descendant_ancestries, as: :descendant, dependent: :delete_all, class_name: "EntityHierarchy"
    has_many :entity_ancestries, as: :hierarchical, dependent: :delete_all, class_name: "EntityHierarchy"

    has_many :frontend_revalidations, as: :entity, dependent: :delete_all

    has_many :orderings, dependent: :destroy, as: :entity

    has_many :ordering_entries, dependent: :delete_all, as: :entity

    has_many_readonly :parent_orderings, through: :ordering_entries, source: :ordering

    has_many :pages, -> { in_default_order }, as: :entity, dependent: :destroy, inverse_of: :entity

    scope :by_title, ->(title) { where(title:) }
    scope :sans_thumbnail, -> { where(arel_json_get(:thumbnail_data, :storage).eq(nil)) }

    scope :filtered_by_schema_version, ->(schemas) { where(schema_version: SchemaVersion.filtered_by(schemas)) }

    scope :with_missing_orderings, -> { where(id: EntityInheritedOrdering.missing.select(:entity_id)) }

    scope :with_schema_name_asc, -> { joins(:schema_definition).merge(SchemaDefinition.order(name: :asc)) }

    scope :with_schema_name_desc, -> { joins(:schema_definition).merge(SchemaDefinition.order(name: :desc)) }

    scope :with_orderings, -> { where(id: Ordering.select(:entity_id)) }
    scope :sans_orderings, -> { where.not(id: Ordering.select(:entity_id)) }

    delegate :auth_path, to: :contextual_parent, allow_nil: true, prefix: :contextual

    strip_attributes only: %i[title]

    before_validation :inherit_hierarchical_parent!

    after_validation :set_temporary_auth_path!, on: :create
    after_validation :maybe_update_auth_path!, on: :update

    after_create :populate_orderings!

    after_save :track_parent_changes!

    after_save :maintain_links!

    after_save :refresh_orderings!

    after_save :extract_core_texts!

    after_save :extract_composed_text!
  end

  # @param [String] ancestor_name
  # @param [Boolean] enforce_known
  # @return [EntityAncestor, nil]
  def ancestor_by_name(ancestor_name, enforce_known: false)
    if enforce_known && !has_known_ancestor?(ancestor_name)
      raise Entities::UnknownAncestor.new(entity: self, ancestor_name:)
    end

    named_ancestors.by_name(ancestor_name).first&.ancestor
  end

  def has_known_ancestor?(name)
    schema_version.has_ancestor?(name)
  end

  # @param [String] schema_name
  # @return [HierarchicalEntity]
  def ancestor_of_type(schema_name)
    entity_breadcrumbs.filtered_by_schema_version(schema_name).first&.crumb
  end

  # @return [String]
  def breadcrumb_label
    title
  end

  # @param [String] identifier
  # @return [Collection, nil]
  def descendant_collection_by(identifier)
    descendant_collections_by(identifier).first
  end

  # @param [String] identifier
  # @raise [ActiveRecord::RecordNotFound]
  # @return [Collection]
  def descendant_collection_by!(identifier)
    descendant_collections_by(identifier).first!
  end

  # @param [String] identifier
  # @return [ActiveRecord::Relation<Collection>]
  def descendant_collections_by(identifier)
    Collection.where(id: entity_descendants.for_collection_filter).by_identifier(identifier)
  end

  # This potentially connects to another "layer" in the hierarchy.
  #
  # For items, it can be an item or a collection.
  #
  # For collections, it can be a collection or a community.
  #
  # For communities, it's always nil.
  #
  # @return [HierarchicalEntity, nil]
  def contextual_parent
    root? ? hierarchical_parent : parent
  end

  # @return [Symbol, nil]
  def contextual_parent_foreign_key
    contextual_parent.then do |parent|
      :"#{parent.hierarchical_child_association}_id" if parent.present?
    end
  end

  # @!scope private
  # @return [String]
  def derive_auth_path
    return unless persisted? && system_slug?

    [contextual_auth_path, system_slug].compact.join(?.)
  end

  # @param [HierarchicalEntity] entity
  def has_descendant?(entity)
    entity_descendants.exists?(descendant: entity)
  end

  # @return [<HierarchicalEntity>]
  def hierarchical_ancestors
    # :nocov:
    hierarchical_ancestor_enumerator.to_a
    # :nocov:
  end

  # @api private
  # @return [Enumerator<HierarchicalEntity>]
  def hierarchical_ancestor_enumerator
    Enumerator.new do |yielder|
      current = contextual_parent

      while current.present?
        yielder << current

        current = current.contextual_parent
      end
    end
  end

  def each_hierarchical_ancestor(&)
    return enum_for(__method__) unless block_given?

    hierarchical_ancestor_enumerator.each(&)
  end

  # @abstract
  # @return [ActiveRecord::Relation<HierarchicalEntity>]
  def hierarchical_children
    self.class.none
  end

  def hierarchical_child_association
    model_name.singular.to_sym
  end

  # @abstract
  def hierarchical_parent
    # :nocov:
    raise NotImplementedError, "Must implement #{self.class}##{__method__}"
    # :nocov:
  end

  def hierarchical_parent_foreign_key
    :"#{hierarchical_parent&.hierarchical_child_association}_id" if hierarchical_parent.present?
  end

  # @see Links::Connect
  # @param [HierarchicalEntity] source
  # @param [String] operator
  # @return [Dry::Monads::Result]
  def link_from!(source, operator:)
    call_operation("links.connect", source, self, operator)
  end

  # @see Links::Connect
  # @param [HierarchicalEntity] target
  # @param [String] operator
  # @return [Dry::Monads::Result]
  def link_to!(target, operator:)
    call_operation("links.connect", self, target, operator)
  end

  # @return [<HierarchicalEntity>]
  def linked_entities
    entity_links.map(&:target)
  end

  # @return [<HierarchicalEntity>]
  def linking_entities
    incoming_links.map(&:source)
  end

  # @see Links::Maintain
  monadic_operation! def maintain_links
    call_operation("links.maintain", self)
  end

  # @see Schemas::Instances::FindOrderingEntry
  # @param [String] identifier the name of an ordering (@see HierarchicalEntity#ordering)
  # @param [HierarchicalEntity] target the entity to search for an entry for
  # @return [Dry::Monads::Success(OrderingEntry)]
  # @return [Dry::Monads::Failure(:ordering_entry_not_found)]
  monadic_operation! def find_ordering_entry(identifier, target)
    call_operation("schemas.instances.find_ordering_entry", self, identifier, target)
  end

  # @param [String] identifier
  # @return [Ordering, nil]
  def ordering(identifier)
    if orderings.loaded?
      orderings.detect { |ord| ord.identifier == identifier }
    else
      orderings.by_identifier(identifier).first
    end
  end

  # @param [String] identifier
  # @raise [ActiveRecord::RecordNotFound]
  # @return [Ordering]
  def ordering!(identifier)
    orderings.by_identifier(identifier).first!
  end

  # @param [String] schema a selector to prune
  # @see Entities::PruneUnharvested
  def prune_unharvested(schema)
    call_operation("entities.prune_unharvested", source: self)
  end

  # @see Entities::PruneUnharvestedJournals
  def prune_unharvested_journals
    call_operation("entities.prune_unharvested_journals", source: self)
  end

  # @see Entities::CalculateAncestors
  monadic_operation! def calculate_ancestors
    call_operation("entities.calculate_ancestors", self)
  end

  # @see Entities::SyncHierarchies
  monadic_operation! def sync_hierarchies
    call_operation("entities.sync_hierarchies", self)
  end

  # @see Schemas::Instances::PopulateOrderings
  # @return [Dry::Monads::Result]
  monadic_operation! def populate_orderings
    call_operation("schemas.instances.populate_orderings", self)
  end

  # @see Schemas::Instances::RefreshOrderings
  # @return [Dry::Monads::Result]
  monadic_operation! def refresh_orderings
    call_operation("schemas.instances.refresh_orderings", self)
  end

  # @see Entities::RevalidateFrontendCache
  # @return [Dry::Monads::Result]
  monadic_operation! def revalidate_frontend_cache
    call_operation("entities.revalidate_frontend_cache", self)
  end

  # @see Entities::RevalidateFrontendCacheJob
  # @return [void]
  def asynchronously_revalidate_frontend_cache!
    Entities::RevalidateFrontendCacheJob.perform_later(self)
  end

  # @see Schemas::Instances::ExtractComposedText
  # @return [Dry::Monads::Success]
  monadic_operation! def extract_composed_text
    call_operation("schemas.instances.extract_composed_text", self)
  end

  # @see Schemas::Instances::WriteCoreTexts
  # @return [Dry::Monads::Success]
  monadic_operation! def extract_core_texts
    call_operation("schemas.instances.write_core_texts", self)
  end

  # @return [<HierarchicalEntity>]
  def self_and_referring_entities
    [self, *entity_breadcrumbs.map(&:crumb), *linking_entities]
  end

  def top_level?
    kind_of?(Community) || (respond_to?(:root?) && root?)
  end

  def has_permitted_actions_for?(user, *actions)
    return false unless persisted?

    contextual_single_permissions.with_permitted_actions_for(user, *actions).exists?
  end

  # If a parent collection changes its community, we need its children to to also inherit that update.
  #
  # So too with items' parents getting new collections.
  #
  # @!scope private
  # @return [void]
  def inherit_hierarchical_parent!
    return if top_level?

    inherited_hierarchical_parent = parent.hierarchical_parent

    return if inherited_hierarchical_parent.blank?

    writer = :"#{inherited_hierarchical_parent.hierarchical_child_association}="

    public_send writer, inherited_hierarchical_parent
  end

  # @see Loaders::ContextualPermissionLoader
  # @return [String]
  def loader_cache_key
    "#{hierarchical_type}:#{hierarchical_id}"
  end

  # @!scope private
  # @return [void]
  def maybe_update_auth_path!
    return unless persisted? && system_slug?

    self.auth_path = derive_auth_path
  end

  # @return [void]
  def set_system_slug!
    super

    update_column :auth_path, derive_auth_path
  end

  def to_entity_tuple
    super.merge(
      slice(
        :schema_version_id,
        :title,
        :created_at,
        :updated_at,
      ).symbolize_keys
    )
  end

  def saved_change_to_contextual_parent?
    saved_change_to_attribute? contextual_parent_foreign_key
  end

  def saved_change_to_hierarchical_parent?
    saved_change_to_attribute? hierarchical_parent_foreign_key
  end

  def should_update_hierarchical_children_after_save?
    saved_change_to_contextual_parent? || saved_change_to_hierarchical_parent? || saved_change_to_auth_path?
  end

  # @see #inherit_hierarchical_parent!
  # @!scope private
  # @return [void]
  def track_parent_changes!
    return unless respond_to?(:children) && should_update_hierarchical_children_after_save?

    Schemas::Orderings.with_asynchronous_refresh do
      # This will have a cascading effect on all descendants, as they should each inherit
      # the updated parent, triggering this method at their depth, and then doing the same
      # for each of their children, and so on.
      children.find_each(&:save!)

      # For collections, this will make sure that items update their auth_paths
      hierarchical_children.find_each(&:save!)
    end
  end

  # @return [void]
  def set_temporary_auth_path!
    self.auth_path = system_slug
  end

  # @!group Templates / Slots

  # @see Entities::PreviewSlot
  # @return [Dry::Monads::Success(Templates::Slots::Instances::Abstract)]
  monadic_operation! def preview_slot(**options)
    call_operation("entities.preview_slot", self, **options)
  end

  monadic_operation! def to_liquid_assigns(**options)
    call_operation("templates.build_assigns", **options, entity: self)
  end

  # @!endgroup
end
