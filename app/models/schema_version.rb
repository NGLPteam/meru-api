# frozen_string_literal: true

# A specific version of a {SchemaDefinition}, used to enumerate the properties and orderings
# that a given {SchemaInstance} can have. The core of its logic is housed {#configuration},
# and it has connections with many key parts of the application.
#
# @see Schemas::Versions::Configuration
# @subsystem Schema
class SchemaVersion < ApplicationRecord
  include ConfiguresContributionRole
  include Liquifies
  include Schemas::Properties::CompilesToSchema
  include Schemas::Static::Namespaced
  include ExposesSchemaProperties
  include SchemaVersionTemplating
  include TimestampScopes

  drop_klass ::Templates::Drops::SchemaVersionDrop

  # @!attribute [r] kind
  # @return ["community", "collection", "item"]
  pg_enum! :kind, as: "schema_kind"

  attr_readonly :declaration, :identifier, :name, :namespace, :number, :parsed, :schema_definition_id

  belongs_to :schema_definition, inverse_of: :schema_versions

  has_many :cached_entity_list_items, inverse_of: :schema_version, dependent: :delete_all, class_name: "Templates::CachedEntityListItem"

  has_many :communities, dependent: :restrict_with_error, inverse_of: :schema_version
  has_many :collections, dependent: :restrict_with_error, inverse_of: :schema_version
  has_many :items, dependent: :restrict_with_error, inverse_of: :schema_version

  has_many :entity_hierarchies, dependent: :delete_all, inverse_of: :schema_version

  has_many_readonly :entities, inverse_of: :schema_version

  has_many_readonly :entity_descendants, inverse_of: :schema_version

  has_many :entity_derived_layout_definitions, inverse_of: :schema_version, dependent: :delete_all

  has_many :layout_definition_hierarchies, inverse_of: :schema_version, dependent: :delete_all

  has_many :schema_version_ancestors, dependent: :delete_all, inverse_of: :schema_version
  has_many :schema_version_descendants, dependent: :delete_all, inverse_of: :target_version, class_name: "SchemaVersionAncestor"
  has_many :schema_version_properties, dependent: :delete_all, inverse_of: :schema_version

  has_many_readonly :schema_version_orderings, inverse_of: :schema_version

  with_options foreign_key: :source_id, inverse_of: :source, class_name: "SchemaVersionAssociation" do
    has_many_readonly :parent_associations, -> { by_name("parent") }
    has_many_readonly :child_associations, -> { by_name("child") }
  end

  has_many :enforced_parent_versions, through: :parent_associations, source: :target
  has_many :enforced_child_versions, through: :child_associations, source: :target

  has_many :entity_links, dependent: :destroy

  has_many :harvest_entities, inverse_of: :schema_version, dependent: :restrict_with_error

  # @!attribute [r] number
  # @return [Semantic::Version]
  attribute :number, :semantic_version

  # @!attribute [rw] configuration
  # @return [Schemas::Versions::Configuration]
  attribute :configuration, Schemas::Versions::Configuration.to_type, default: -> { {} }

  scope :by_number, ->(number) { where(number:) }
  scope :by_schema_definition, ->(schema_definition) { where(schema_definition:) if schema_definition.present? }
  scope :by_kind, ->(kind) { joins(:schema_definition).merge(SchemaDefinition.by_kind(kind)) }

  scope :current, -> { where(current: true) }

  scope :in_default_order, -> { joins(:schema_definition).merge(SchemaDefinition.in_default_order).order(parsed: :desc) }
  scope :by_position, -> { order(position: :desc) }

  delegate :has_ordering?, :ordering_definition_for, :property_for, :property_paths, :type_mapping, to: :configuration, allow_nil: true
  delegate :identifier, :namespace, :version, to: :configuration, allow_nil: true, prefix: :configured

  before_validation :extract_ancestor_data!
  before_validation :extract_reference_paths!

  after_create :reorder_versions!

  after_update :maybe_reorder_versions!

  after_save :extract_ancestors!

  after_save :extract_properties!

  validates :configuration, store_model: true

  validate :configuration_matches_definition!

  alias_attribute :system_slug, :declaration

  # @!attribute [r] gem_version
  # @note Used for comparison with Gem::Requirements
  # @see Schemas::Associations::SatisfiedBy
  # @return [Gem::Version]
  def gem_version
    Gem::Version.new(number)
  end

  # @param [#to_s] name
  def has_ancestor?(name)
    name.to_s.in?(ancestor_names)
  end

  # @!attribute [r] label
  # A human-readable label for this particular schema version.
  # @return [String]
  def label
    "#{name} v#{number}"
  end

  def inspect
    "<SchemaVersion[#{declaration.inspect}]>"
  end

  monadic_operation! def maintain_associations
    call_operation("schemas.versions.maintain_associations", self)
  end

  def read_searchable_properties
    call_operation("schemas.versions.read_searchable_properties", self)
  end

  def searchable_properties
    read_searchable_properties.value_or([])
  end

  # @see Schemas::Instances::PropertySet#schema
  # @see Schemas::Header
  # @return [Hash]
  def to_header
    slice(:id, :identifier, :namespace).merge(version: number.to_s)
  end

  # Options to include when building a {Schemas::Properties::Context} for
  # a version, or an entity that implements this version.
  #
  # @return [Hash]
  def to_property_context
    {
      version: self,
      type_mapping:,
    }
  end

  # Compute a validation contract for this schema.
  #
  # @see Schemas::Properties::CompileContract
  # @return [ApplicationContract]
  def to_validation_contract
    call_operation("schemas.properties.compile_contract", self).value!
  end

  # Calculate an array of attributes that will be turned
  # into associated {SchemaVersionProperty} records.
  #
  # @api private
  # @see Schemas::Versions::ExtractProperties
  # @see Schemas::Versions::Configuration#to_version_properties
  # @return [<Hash>]
  def to_version_properties
    shared_attributes = slice(:schema_definition_id).merge(schema_version_id: id)

    configuration.to_version_properties.map do |attributes|
      attributes.merge(shared_attributes)
    end
  end

  # @!group Hooks

  # @api private
  # @return [void]
  def configuration_matches_definition!
    %i[namespace identifier kind].each do |trait|
      expected = schema_definition.public_send trait
      actual = configuration.public_send trait

      next if expected == actual

      errors.add :configuration, :mismatched_trait, trait:, expected:, actual:
    end
  end

  # @api private
  # @return [void]
  monadic_operation! def extract_ancestors
    call_operation("schemas.versions.extract_ancestors", self)
  end

  # @api private
  # @return [void]
  monadic_operation! def extract_properties
    call_operation("schemas.versions.extract_properties", self)
  end

  # @return [void]
  def maybe_reorder_versions!
    return unless should_reorder_versions?

    reorder_previous_definition_versions! if should_reorder_previous_definition_versions?

    reorder_versions!
  end

  # @api private
  # @see Schemas::Versions::Reorder
  # @return [void]
  monadic_operation! def reorder_versions
    call_operation("schemas.versions.reorder", schema_definition)
  end

  # @!endgroup

  # @api private
  # Reload the static version if applicable.
  #
  # @see Schemas::Versions::Reload
  # @return [Dry::Monads::Result]
  def reload_static
    call_operation("schemas.versions.reload", self)
  end

  # @api private
  # Reload the static version if applicable.
  #
  # @see Schemas::Versions::Reload
  # @see #reload_static
  # @return [SchemaVersion]
  def reload_static!
    reload_static.value!
  end

  private

  # @return [void]
  def extract_ancestor_data!
    self.ancestor_names = Array(configuration.ancestors&.pluck(:name))
    self.has_ancestors = ancestor_names.present?
  end

  # @return [void]
  def extract_reference_paths!
    self.collected_reference_paths = Array(configuration&.collected_reference_paths)
    self.scalar_reference_paths = Array(configuration&.scalar_reference_paths)
    self.text_reference_paths = Array(configuration&.text_reference_paths)
  end

  def should_reorder_versions?
    saved_change_to_schema_definition_id? || saved_change_to_number?
  end

  def should_reorder_previous_definition_versions?
    schema_definition_id_before_last_save.present? && schema_definition_id != schema_definition_id_before_last_save
  end

  class << self
    # @param [String] needle
    # @return [SchemaVersion]
    def [](needle)
      MeruAPI::Container["schemas.versions.find"].call(needle).value_or do |(_, message)|
        raise ActiveRecord::RecordNotFound, message
      end
    end

    # @raise [ActiveRecord::RecordNotFound] if no current version set
    # @return [SchemaVersion]
    def default_collection
      by_tuple("default", "collection").latest!
    end

    # @raise [ActiveRecord::RecordNotFound] if no current version set
    # @return [SchemaVersion]
    def default_community
      by_tuple("default", "community").latest!
    end

    # @raise [ActiveRecord::RecordNotFound] if no current version set
    # @return [SchemaVersion]
    def default_item
      by_tuple("default", "item").latest!
    end

    # @param [<String, SchemaVersion>] schemas (@see Schemas::Versions::Find)
    # @return [ActiveRecord::Relation<SchemaVersion>]
    def filtered_by(schemas)
      schema_versions = Array(schemas).map do |needle|
        MeruAPI::Container["schemas.versions.find"].call(needle).value_or(nil)
      end.compact

      if schema_versions.present?
        where(id: schema_versions)
      elsif schemas.present?
        none
      else
        all
      end
    end

    # @raise [ActiveRecord::RecordNotFound] if no current version set
    # @return [SchemaVersion]
    def latest!
      current.first!
    end

    # @param [:latest, String] number
    # @raise [ActiveRecord::RecordNotFound] if current version set or no number found
    # @return [SchemaVersion]
    def lookup(number)
      number == :latest ? latest! : by_number(number).only_one!
    end

    # @param [String] number
    # @return [SchemaVersion]
    def lookup_or_initialize(number, schema_definition: nil)
      by_schema_definition(schema_definition).by_number(number).only_one_or_initialize
    end
  end
end
