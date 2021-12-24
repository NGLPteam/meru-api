# frozen_string_literal: true

class SchemaVersionProperty < ApplicationRecord
  include WrapsSchemaProperty

  belongs_to :schema_definition, inverse_of: :schema_version_properties
  belongs_to :schema_version, inverse_of: :schema_version_properties

  has_many :entity_orderable_properties, inverse_of: :schema_version_property, dependent: :destroy
  has_many :named_variable_dates, inverse_of: :schema_version_property, dependent: :destroy

  scope :by_schema_version, ->(schema) { where(schema_version: schema) }

  validates :path, presence: true, uniqueness: { scope: :schema_version_id }
  validates :kind, :type, presence: true

  # @see Schemas::Instances::ExtractOrderableProperties
  # @return [Hash]
  def to_entity_property_attributes
    slice(:path, :type).merge(schema_version_property_id: id)
  end

  # @see Schemas::Instances::ExtractOrderableProperties
  # @return [Hash]
  def to_named_variable_date_attributes
    slice(:path).merge(schema_version_property_id: id)
  end

  class << self
    # @return [ActiveRecord::Relation<SchemaVersionProperty>]
    def filtered_by_schema_version(*schemas)
      schemas.flatten!

      return all if schemas.blank?

      schema_versions = Array(schemas).map do |needle|
        WDPAPI::Container["schemas.versions.find"].call(needle).value_or(nil)
      end.compact

      return none if schema_versions.blank?

      where(schema_version: schema_versions)
    end
  end
end
