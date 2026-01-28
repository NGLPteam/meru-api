# frozen_string_literal: true

# A dynamic ordering for a {SchemaInstance}. By default, these are provided by the
# entity's associated {SchemaVersion}, but there exists the ability for administrators
# to create custom orderings for specific entities that have all the same abilities.
#
# @see Schemas::Orderings::Definition
# @see Schemas::Versions::Configuration#orderings
class Ordering < ApplicationRecord
  include AssignsPolymorphicForeignKey
  include Liquifies
  include ReloadAfterSave
  include TimestampScopes

  drop_klass Templates::Drops::OrderingDrop

  attr_readonly :constant, :disabled, :hidden, :identifier, :name

  belongs_to :entity, polymorphic: true
  belongs_to :schema_version

  belongs_to :community, optional: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  belongs_to :handled_schema_definition, class_name: "SchemaDefinition", optional: true,
    inverse_of: :handling_orderings

  has_one :schema_definition, through: :schema_version

  has_one_readonly :ordering_date_range, inverse_of: :ordering

  has_one_readonly :ordering_entry_count, inverse_of: :ordering

  has_many :ordering_entries, inverse_of: :ordering, dependent: :delete_all

  has_many :ordering_entry_ancestor_links, inverse_of: :ordering, dependent: :delete_all
  has_many :ordering_entry_sibling_links, inverse_of: :ordering, dependent: :delete_all

  has_many :named_variable_dates, through: :ordering_entries

  has_many :normalized_entities, through: :ordering_entries

  has_many :ordering_invalidations, inverse_of: :ordering, dependent: :delete_all

  has_many :ordering_template_instances,
    class_name: "Templates::OrderingInstance",
    inverse_of: :ordering,
    dependent: :nullify

  # @!attribute [rw] definition
  # @return [Schemas::Orderings::Definition]
  attribute :definition, Schemas::Orderings::Definition.to_type, default: proc { {} }

  scope :by_entity, ->(entity) { where(entity:) }
  scope :by_identifier, ->(identifier) { where(identifier:) }

  scope :deterministically_ordered, -> { reorder(position: :asc, name: :asc, identifier: :asc) }

  scope :enabled, -> { where(disabled_at: nil) }
  scope :disabled, -> { where.not(disabled_at: nil) }
  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }
  scope :with_visible_entries, -> { where(id: OrderingEntry.currently_visible.select(:ordering_id)) }

  delegate :header, :footer, :covers_schema?, :tree_mode?, to: :definition

  delegate :schemas, allow_nil: true, to: "definition.filter", prefix: :filter

  before_validation :set_handled_schema_definition!
  before_validation :sync_inherited!
  before_validation :track_pristine!

  # A restrictive pattern to ensure that ordering identifiers are sane, URL-safe,
  # and consistent across the application.
  IDENTIFIER_FORMAT = /\A[a-z](?:[a-z0-9]*|(?:(?<![-_])[_-](?![_-])))*[a-z0-9]\z/

  validates :identifier, presence: true, format: { with: IDENTIFIER_FORMAT }, uniqueness: { scope: %i[entity_type entity_id] }
  validates :definition, store_model: true

  after_save :refresh!

  assign_polymorphic_foreign_key! :entity, :community, :collection, :item

  # @return [void]
  def asynchronously_refresh!
    Schemas::Orderings::RefreshJob.perform_later self
  end

  # @return [void]
  def asynchronously_reset!
    Schemas::Orderings::ResetJob.perform_later self
  end

  # @see Schemas::Orderings::OrderBuilder::Compile
  # @return [Schemas::Ordering::OrderExpression]
  def compile_ordering_expression
    call_operation("schemas.orderings.order_builder.compile", definition)
  end

  def defined_in_schema?
    schema_version.has_ordering? identifier
  end

  # @return [void]
  def disable!
    self.disabled_at = Time.current

    save!
  end

  def disabled?
    disabled_at.present?
  end

  # @return [void]
  def enable!
    update_attribute :disabled_at, nil
  end

  # @see Schemas::Orderings::FindEntry
  # @param [HierarchicalEntity] entity
  # @return [Dry::Monads::Success(OrderingEntry)]
  # @return [Dry::Monads::Failure(:ordering_entry_not_found)]
  monadic_operation! def find_entry(entity)
    call_operation("schemas.orderings.find_entry", self, entity)
  end

  # @see Schemas::Orderings::Invalidate
  monadic_operation! def invalidate(...)
    call_operation("schemas.orderings.invalidate", self, ...)
  end

  # @return [<Schemas::Orderings::OrderDefinition>]
  def order_definitions
    Array(definition.order)
  end

  # @param [HierarchicalEntity] refreshing_entity
  def refreshes_for?(refreshing_entity)
    entity == refreshing_entity || covers_schema?(refreshing_entity)
  end

  # @see Schemas::Orderings::Refresh
  # @return [Dry::Monads::Result]
  monadic_operation! def refresh
    call_operation("schemas.orderings.refresh", self)
  end

  # @see Schemas::Orderings::Reset
  # @return [Dry::Monads::Result]
  monadic_operation! def reset
    call_operation("schemas.orderings.reset", self)
  end

  # @return [Schemas::Orderings::Definition, nil]
  def pristine_definition
    return unless defined_in_schema?

    schema_version.ordering_definition_for identifier
  end

  # @api private
  # @return [void]
  def sync_inherited!
    self.inherited_from_schema = schema_version ? schema_version.has_ordering?(identifier) : false
  end

  # @api private
  # @return [void]
  def track_pristine!
    unless inherited_from_schema?
      self.pristine = false

      return
    end

    self.pristine = pristine_definition.as_json == definition.as_json
  end

  # @api private
  # @see Schemas::Orderings::Definition#handled_schema_definition
  # @return [void]
  def set_handled_schema_definition!
    self.handled_schema_definition = definition.handled_schema_definition
  end

  # @!group Stats

  # @see Schemas::Orderings::Stats::Calculate
  # @see Schemas::Orderings::Stats::Calculator
  # @return [Dry::Monads::Success(Ordering)]
  monadic_operation! def calculate_stats(**options)
    call_operation("schemas.orderings.stats.calculate", self, **options)
  end

  # @see Schemas::Orderings::Stats::CalculateDates
  # @see Schemas::Orderings::Stats::DatesCalculator
  # @return [Dry::Monads::Success(Ordering)]
  monadic_operation! def calculate_dates(**options)
    call_operation("schemas.orderings.stats.calculate_dates", self, **options)
  end

  # @see Schemas::Orderings::Stats::CountEntries
  # @see Schemas::Orderings::Stats::EntriesCounter
  # @return [Dry::Monads::Success(Ordering)]
  monadic_operation! def count_entries(**options)
    call_operation("schemas.orderings.stats.count_entries", self, **options)
  end

  # @!endgroup

  class << self
    # @see Schemas::Definitions::Find
    # @param [String] slug
    # @return [ActiveRecord::Relation<Ordering>]
    def by_handled_schema_definition(slug)
      MeruAPI::Container["schemas.definitions.find"].(slug).fmap do |schema_definition|
        where(handled_schema_definition: schema_definition)
      end.value_or do
        none
      end
    end

    # @see .by_handled_schema_definition
    # @param [String] slug
    # @return [Ordering, nil]
    def handling_schema(slug)
      by_handled_schema_definition(slug).first
    end

    # @param [HierarchicalEntity] entity
    # @return [ActiveRecord::Relation<Ordering>]
    def owned_by_or_ordering(entity)
      base_query = unscoped.by_entity(entity.self_and_referring_entities)

      base_query = base_query.or unscoped.where(id: entity.parent_orderings)

      base_query = base_query.or unscoped.where(id: OrderingEntry.linking_to(entity).select(:ordering_id))

      where id: base_query
    end
  end
end
