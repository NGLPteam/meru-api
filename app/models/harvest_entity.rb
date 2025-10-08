# frozen_string_literal: true

# A staging ground for an {Item} or a {Collection}, extracted
# from metadata contained within a {HarvestRecord}.
class HarvestEntity < ApplicationRecord
  include HasHarvestErrors
  include ScopesForIdentifier
  include ReferencesCachedAssets
  include TimestampScopes
  include Dry::Monads[:result]

  has_closure_tree

  pg_enum! :entity_kind, as: :child_entity_kind, allow_blank: false

  belongs_to :harvest_record, inverse_of: :harvest_entities

  belongs_to :entity, polymorphic: true, optional: true

  belongs_to :existing_parent, polymorphic: true, optional: true

  belongs_to :schema_version, inverse_of: :harvest_entities

  has_many :harvest_attempt_entity_links, inverse_of: :harvest_entity, dependent: :delete_all

  has_one :harvest_configuration, through: :harvest_record

  has_many :harvest_contributions, inverse_of: :harvest_entity, dependent: :destroy

  has_many :harvest_messages, inverse_of: :harvest_entity, dependent: :destroy

  attribute :extracted_attributes, Harvesting::Entities::ExtractedAttributes.to_type
  attribute :extracted_properties, :indifferent_hash
  attribute :extracted_assets, Harvesting::Assets::Mapping.to_type, default: proc { {} }
  attribute :extracted_links, Harvesting::Links::Mapping.to_type, default: proc { {} }

  scope :in_default_order, -> { build_default_order_scope }

  scope :filtered_by_schema_version, ->(schemas) { where(schema_version: SchemaVersion.filtered_by(schemas)) }
  scope :for_metadata_format, ->(metadata_format) { joins(:harvest_record).merge(HarvestRecord.for_metadata_format(metadata_format)) }
  scope :with_entity, -> { where.not(entity_id: nil) }

  scope :with_esploro_format, -> { for_metadata_format "esploro" }
  scope :with_jats_format, -> { for_metadata_format "jats" }
  scope :with_mets_format, -> { for_metadata_format "mets" }
  scope :with_mods_format, -> { for_metadata_format "mods" }
  scope :with_oaidc_format, -> { for_metadata_format "oaidc" }
  scope :with_pressbooks_format, -> { for_metadata_format "pressbooks" }

  scope :with_extracted_properties, ->(props) { where(arel_json_contains(:extracted_properties, props)) }
  scope :with_existing_parent, ->(parent) { where(existing_parent: parent) }
  scope :with_extracted_scalar_asset, ->(full_path) { where(arel_has_extracted_scalar_asset(full_path)) }

  validates :identifier, presence: true, uniqueness: { scope: :harvest_record_id }
  validate :exclusive_parentage!

  # @see Harvesting::Entities::ExtractedAttributes#to_assign
  # @return [Hash]
  def attributes_to_assign
    extracted_attributes.to_assign
  end

  def inspect
    "HarvestEntity(#{identifier.inspect}, root: #{root?})"
  end

  def has_assets?
    extracted_assets.present?
  end

  def has_entity?
    entity.present?
  end

  def has_existing_parent?
    existing_parent_id.present?
  end

  monadic_operation! def prune_entities(...)
    call_operation("harvesting.entities.prune_entities", self, ...)
  end

  # @see Harvesting::Entities::Upsert
  # @return [void]
  monadic_operation! def upsert(...)
    call_operation("harvesting.entities.upsert", self, ...)
  end

  # @see Harvesting::Entities::UpsertAssets
  monadic_operation! def upsert_assets
    call_operation("harvesting.entities.upsert_assets", self)
  end

  private

  def flatten_reason(reason)
    case reason
    in Failure[:invalid, ApplicationRecord => model]
      {
        code: :invalid,
        model: model.model_name,
        id: model.id,
        errors: model.errors.as_json,
      }
    else
      reason.as_json
    end
  end

  # @return [void]
  def exclusive_parentage!
    # :nocov:
    errors.add :base, "Child harvest entities cannot have an existing parent set" if !root? && has_existing_parent?
    # :nocov:
  end

  class << self
    # @return [ActiveRecord::Relation]
    def existing_entity_ids
      with_entity.select(:entity_id)
    end

    # @param [String] full_path
    # @return [Arel::Nodes::InfixOperation]
    def arel_has_extracted_scalar_asset(full_path)
      expr = arel_quote %{$.scalar[*].full_path ? (@ == #{full_path.to_s.inspect})}

      arel_infix "@?", arel_table[:extracted_assets], expr
    end

    def build_default_order_scope
      roots_first = arel_case do |stmt|
        stmt.when(arel_table[:parent_id].eq(nil)).then(1)
        stmt.else(999)
      end.asc

      kind_order = arel_case(arel_table[:metadata_kind]) do |stmt|
        stmt.when("volume").then(1)
        stmt.when("issue").then(2)
        stmt.when("article").then(3)
        stmt.else(99)
      end.asc

      order(roots_first, kind_order)
    end
  end
end
