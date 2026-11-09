# frozen_string_literal: true

module EsploroSchema
  # An interface that defines consolidations between {EsploroSchema::Elements::EsploroRecord}
  # and {EsploroSchema::Elements::EsploroData}.
  #
  # It is used in {EsploroSchema::Record}.
  #
  # @api private
  module RecordAndDataConsolidation
    extend ActiveSupport::Concern

    DATA_PROPERTIES = EsploroSchema::Elements::EsploroData.properties

    RECORD_PROPERTIES = EsploroSchema::Elements::EsploroRecord.properties.reject do |prop|
      prop.name == :data
    end

    DERIVE_ALL_PROPERTIES_ASSIGNMENTS = RECORD_PROPERTIES.map do |prop|
      prop.derive_assignment
    end.join("\n")

    RECORD_PROPERTIES.each do |prop|
      attr_reader prop.normalized_name

      class_eval prop.normalizer_method_body, __FILE__, __LINE__

      # rubocop:disable-next Style/AccessModifierDeclarations
      private prop.normalizer_method
    end

    private

    class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def derive_all_properties!
      #{DERIVE_ALL_PROPERTIES_ASSIGNMENTS}
    end
    RUBY

    private :derive_all_properties!

    # @param [Symbol] name
    # @return [Array]
    def retrieve_collected_value_for(name)
      record_values = Array(esploro_record.__send__(name))

      data_values = Array(esploro_data.try(name))

      record_values | data_values
    end

    # @param [Symbol] name
    # @return [Object]
    def retrieve_value_for(name)
      record_value = esploro_record.__send__(name)

      return record_value unless record_value.nil?

      esploro_data.try(name)
    end

    # @param [Symbol] name
    # @return [<Object>]
    def retrieve_wrapped_value_for(name)
      esploro_record.__send__(name)
    end
  end
end
