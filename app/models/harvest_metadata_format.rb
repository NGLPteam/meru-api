# frozen_string_literal: true

# A model that represents supported metadata formats for harvesting in Meru.
class HarvestMetadataFormat < ::ApplicationFrozenRecord
  include Dry::Core::Equalizer.new(:name)
  include Dry::Core::Memoizable

  schema!(types: ::Harvesting::TypeRegistry) do
    required(:name).filled(:string)
    required(:underlying_data_format).filled(:underlying_data_format)
    required(:disabled).value(:bool)
    optional(:oai_metadata_prefix).value(:string)
  end

  calculates! :oai_metadata_prefix do |record|
    record["name"]
  end

  default_attributes!(
    disabled: false
  )

  self.primary_key = :name

  add_index :name, unique: true

  alias_attribute :metadata_format, :name

  scope :enabled, -> { where(disabled: false) }
  scope :disabled, -> { where(disabled: true) }
  scope :xml, -> { where(underlying_data_format: "xml") }

  klass_name_pair! :context do
    "harvesting/metadata/#{name}/context".camelize(:upper)
  end

  klass_name_pair! :oai_testing_format do
    "harvesting/testing/oai/#{name}/format".camelize(:upper)
  end

  # @return [::OAI::Provider::Metadata::Format]
  def oai_testing_format
    oai_testing_format_klass.instance
  end

  # @param [HarvestRecord] record
  # @return [Harvesting::Metadata::Context]
  def context_for(record)
    # :nocov:
    raise "invalid metadata format for record: #{record.metadata_format}" if record.metadata_format != name
    # :nocov:

    context_klass.new(self, record)
  end

  class << self
    # @param [HarvestRecord] record
    # @return [Harvesting::Metadata::Context]
    def context_for(record)
      metadata_format = find(record.metadata_format)

      metadata_format.context_for(record)
    end
  end
end
