# frozen_string_literal: true

# This represents an "instance" of a {SchemaVersion}.
#
# An instance can be a {Community}, a {Collection}, or an {Item}.
#
# @see Schemas::Types::SchemaInstance
module HasSchemaDefinition
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include EntityReferent
  include ExposesSchemaProperties

  included do
    belongs_to :schema_definition
    belongs_to :schema_version

    has_many :schematic_collected_references, -> { with_valid_path.in_order.preload(:referent) }, as: :referrer, dependent: :destroy, inverse_of: :referrer do
      # @return [{ String => <ApplicationRecord>, nil }]
      def to_reference_map
        each_with_object({}) do |ref, h|
          h[ref.path] ||= []

          next if ref.referent.blank?

          h[ref.path] << ref.referent
        end
      end
    end

    has_many :schematic_scalar_references, -> { with_valid_path.preload(:referent) }, as: :referrer, dependent: :destroy, inverse_of: :referrer do
      # @return [{ String => ApplicationRecord, nil }]
      def to_reference_map
        each_with_object({}) do |ref, h|
          next if ref.referent.blank?

          h[ref.path] = ref.referent
        end
      end
    end

    has_many :schematic_texts, -> { with_valid_path }, as: :entity, dependent: :destroy, inverse_of: :entity do
      # @return [{ String => FullTextContent, nil }]
      def to_reference_map
        each_with_object({}) do |text, h|
          next if text.content.blank?

          h[text.path] = text.to_reference
        end
      end
    end

    has_many :entity_orderable_properties, as: :entity, dependent: :destroy

    attribute :properties, Schemas::Instances::PropertySet.to_type, default: proc { { values: {} } }

    before_validation :enforce_schema_definition!, if: :schema_version_id_changed?
    before_validation :maybe_sign_properties!

    after_save :apply_pending_properties!

    delegate :kind, to: :schema_version, prefix: true, allow_nil: true

    validate :enforce_schema_kind!, if: :should_check_schema_kind?
  end

  # @return [Hash, nil]
  attr_accessor :pending_properties

  # @param [SchemaVersion] schema_version
  # @param [Hash] new_values
  # @return [Dry::Monads::Result]
  monadic_operation! def alter_version(schema_version, new_values, strategy: :apply)
    call_operation("schemas.instances.alter_version", self, schema_version, new_values, strategy:)
  end

  # @param [SchemaVersion] schema_version
  # @param [Hash] new_values
  # @return [Dry::Monads::Result]
  monadic_operation! def alter_version_only(schema_version)
    call_operation("schemas.instances.alter_version", self, schema_version, {}, strategy: :skip)
  end

  # @see Schemas::Instances::Apply
  # @param [Hash] values
  # @return [Dry::Monads::Result]
  monadic_operation! def apply_properties(values)
    call_operation("schemas.instances.apply", self, values)
  end

  # @api private
  # @return [void]
  def apply_pending_properties!
    return if pending_properties.blank?

    begin
      pending = pending_properties

      self.pending_properties = nil

      apply_properties!(pending)
    rescue Dry::Monads::UnwrapError => e
      # :nocov:
      self.pending_properties = pending

      raise e
      # :nocov:
    end
  end

  # @see Schemas::Instances::ExtractOrderableProperties
  # @param [Schemas::Properties::Context, nil] context
  # @return [void]
  monadic_operation! def extract_orderable_properties(context: nil)
    call_operation("schemas.instances.extract_orderable_properties", self, context:)
  end

  # @see Schemas::Instances::ExtractSearchableProperties
  # @param [Schemas::Properties::Context, nil] context
  # @return [void]
  monadic_operation! def extract_searchable_properties(context: nil)
    call_operation("schemas.instances.extract_searchable_properties", self, context:)
  end

  # @see Schemas::Instances::PatchProperties
  # @param [Hash] values
  # @return [Dry::Monads::Result]
  monadic_matcher! def patch_properties(values)
    call_operation("schemas.instances.patch_properties", self, values)
  end

  # @see Schemas::Instances::Reindex
  # @return [void]
  monadic_operation! def reindex
    call_operation("schemas.instances.reindex", self)
  end

  # Write a single property value to a schema.
  #
  # @see #apply_properties
  # @see Schemas::Instances::PropertyWriter
  # @see Schemas::Instances::WriteProperty
  monadic_operation! def write_property(path, value)
    call_operation("schemas.instances.write_property", self, path, value)
  end

  # @return [String]
  def inspect
    schema_suffix = properties&.schema&.suffix

    "#<#{self.class}#{schema_suffix} (#{title.inspect})>"
  end

  # @see Schemas::Instances::Validate
  # @return [Hash]
  def validate_schema_properties(context: nil)
    call_operation("schemas.instances.validate", self, context:).value!
  end

  # @api private
  # @return [void]
  def enforce_schema_definition!
    self.schema_definition_id = schema_version.schema_definition_id
  end

  # @api private
  # @return [void]
  def enforce_schema_kind!
    return if schema_version_kind.blank? || schema_kind_matches?

    errors.add :schema_version_id, "must be a #{schema_kind}, got #{schema_version_kind}"
  end

  # @api private
  # @return [void]
  def maybe_sign_properties!
    return if properties&.schema&.valid?

    self.properties ||= {}
    self.properties.schema = schema_version.to_header

    properties_will_change!
  end

  # @!attribute [r] schema_kind
  # @return ["community", "collection", "item"]
  def schema_kind
    model_name.singular
  end

  # Checks {#schema_kind} against {SchemaVersion#kind}.
  def schema_kind_matches?
    schema_kind == schema_version_kind.to_s
  end

  # @api private
  def should_check_schema_kind?
    new_record? || schema_version_id_changed?
  end

  def to_entity_pair
    slice(:entity_type).merge(entity_id: id)
  end
end
