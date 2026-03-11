# frozen_string_literal: true

# A connection between two {HierarchicalEntity entities}.
#
# This model also stores a reference to itself in {Entity}
# in order to facilitate authorization and hierarchical
# fetching.
class EntityLink < ApplicationRecord
  include HasSystemSlug
  include ManualListTarget
  include MatchesScopes
  include ReferencesEntityVisibility
  include SyncsEntities
  include TimestampScopes

  pg_enum! :operator, as: :link_operator, prefix: :operator

  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  belongs_to :schema_version, inverse_of: :entity_links

  has_one_readonly :entity_visibility, primary_key: %i[target_type target_id], foreign_key: %i[entity_type entity_id]

  has_one :schema_definition, through: :schema_version

  has_many :ordering_entries, as: :entity, dependent: :destroy

  belongs_to :source_community, optional: true
  belongs_to :source_collection, optional: true
  belongs_to :source_item, optional: true
  belongs_to :target_community, optional: true
  belongs_to :target_collection, optional: true
  belongs_to :target_item, optional: true

  scope :by_source, ->(source) { where(source:) }
  scope :by_target, ->(target) { where(target:) }
  scope :by_source_or_target, ->(entity) { where(id: unscoped.by_source(entity).or(unscoped.by_target(entity))) }

  before_validation :calculate_auth_path!
  before_validation :calculate_scope!
  before_validation :sync_schema_version!

  validate :enforce_types!
  validate :disallow_parents!
  validate :disallow_self!

  validates :auth_path, :scope, presence: true
  validates :scope, inclusion: { in: Links::Types::SCOPE_VALUES }
  validates :target_id, uniqueness: { scope: %i[source_type source_id target_type] }

  after_save :refresh_source_orderings!, unless: :maintenance_mode?

  # We want to skip refreshing source orderings during link maintenance,
  # since this will already happen as part of the entity's maintenance.
  #
  # @see #check!
  # @see Links::Maintain
  # @return [Boolean]
  attr_accessor :maintenance_mode

  alias maintenance_mode? maintenance_mode

  # @see Links::Maintain
  # @return [void]
  def check!
    self.maintenance_mode = true

    if valid?
      save!
    else
      destroy!
    end
  ensure
    self.maintenance_mode = false
  end

  # @api private
  # @return [String, nil]
  def calculate_auth_path
    return unless source.present? && target.present?

    "#{source.auth_path}._.#{target.system_slug}"
  end

  # @api private
  # @return [void]
  def calculate_auth_path!
    self.auth_path = calculate_auth_path
  end

  # @api private
  # @return [String, nil]
  def calculate_scope
    call_operation("links.calculate_scope", source_type, target_type).value_or(nil)
  end

  # @api private
  # @return [void]
  def calculate_scope!
    self.scope = calculate_scope
  end

  def entity_scope = scope

  # @return [Entities::Types::EntitySubmissionStatus]
  def entity_submission_status = target.try(:submission_status) || super

  def has_valid_source? = source.kind_of?(HierarchicalEntity)

  def has_valid_target? = target.kind_of?(HierarchicalEntity)

  def hierarchical_id = target_id

  def hierarchical_type = target_type

  # @api private
  # @return [void]
  def disallow_parents!
    errors.add :source, :linked_to_parent if source == target.parent
    errors.add :target, :linked_to_parent if source.parent == target
  end

  # @api private
  # @return [void]
  def disallow_self!
    errors.add :target, :linked_to_itself if source == target
  end

  # @api private
  # @return [void]
  def enforce_types!
    errors.add :source, :must_be_entity unless has_valid_source?
    errors.add :target, :must_be_entity unless has_valid_target?
  end

  # @api private
  # @return [void]
  def sync_schema_version!
    self.schema_version = target.respond_to?(:schema_version) ? target.schema_version : nil
  end

  # @return [Hash]
  def to_entity_tuple
    target.to_entity_tuple.merge(
      link_operator: operator,
    )
  end

  # @api private
  # @return [void]
  def refresh_source_orderings!
    source.refresh_orderings!
  end

  class << self
    # @param [HierarchicalEntity] origin
    # @return [Arel::Nodes::SqlLiteral]
    def sources_and_targets_for(origin)
      sources = sources_for origin

      targets = targets_for origin

      Arel::Nodes::UnionAll.new(sources, targets)
    end

    # @param [HierarchicalEntity] target
    # @return [Arel::Nodes::SqlLiteral]
    def sources_for(target)
      hierarchical_type = arel_table[:source_type].as("hierarchical_type")
      hierarchical_id = arel_table[:source_id].as("hierarchical_id")

      arel_quote_query unscoped.by_target(target).select(hierarchical_type, hierarchical_id)
    end

    # @param [HierarchicalEntity] source
    # @return [Arel::Nodes::SqlLiteral]
    def targets_for(source)
      hierarchical_type = arel_table[:source_type].as("hierarchical_type")
      hierarchical_id = arel_table[:source_id].as("hierarchical_id")

      arel_quote_query unscoped.by_source(source).select(hierarchical_type, hierarchical_id)
    end
  end
end
