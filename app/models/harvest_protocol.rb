# frozen_string_literal: true

# A model that represents supported protocols for harvesting in Meru.
class HarvestProtocol < ::ApplicationFrozenRecord
  include Dry::Core::Equalizer.new(:name)
  include Dry::Core::Memoizable

  schema!(types: ::Harvesting::TypeRegistry) do
    required(:name).filled(:string)
    required(:has_sets).value(:bool)
    required(:supports_extract_record).value(:bool)
    required(:supports_extract_records).value(:bool)
    required(:supports_extract_sets).value(:bool)
  end

  default_attributes!(
    has_sets: true,
    supports_extract_record: false,
    supports_extract_records: true,
    supports_extract_sets: false
  )

  self.primary_key = :name

  add_index :name, unique: true

  alias_attribute :protocol_name, :name

  klass_name_pair! :context do
    "harvesting/protocols/#{name}/context".camelize(:upper)
  end

  # @note currently static
  klass_name_pair! :record_batch_extractor do
    "harvesting/protocols/#{name}/record_batch_extractor".camelize(:upper)
  end

  # @note currently static
  klass_name_pair! :record_batch_processor do
    "harvesting/protocols/record_batch_processor".camelize(:upper)
  end

  klass_name_pair! :record_extractor do
    "harvesting/protocols/#{name}/record_extractor".camelize(:upper)
  end

  klass_name_pair! :record_processor do
    "harvesting/protocols/#{name}/record_processor".camelize(:upper)
  end

  klass_name_pair! :set_extractor do
    if supports_extract_sets?
      "harvesting/protocols/#{name}/set_extractor".camelize(:upper)
    else
      "harvesting/protocols/set_extractor".camelize(:upper)
    end
  end

  # @param [HarvestSource] source
  # @return [Harvesting::Metadata::Context]
  def context_for(source)
    # simplecov:disable
    raise "invalid protocol for source: #{source.protocol}" if source.protocol != name
    # simplecov:enable

    context_klass.new(self, source)
  end

  class << self
    # @param [HarvestSource] source
    # @return [Harvesting::Metadata::Context]
    def context_for(source)
      protocol = find(source.protocol)

      protocol.context_for(source)
    end
  end
end
