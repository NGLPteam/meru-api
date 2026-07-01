# frozen_string_literal: true

module EsploroSchema
  # This acts as a normalized interface for {EsploroSchema::Elements::EsploroRecord}
  # in a way that will composite attributes included on {EsploroSchema::Elements::EsploroData}.
  class Record
    include EsploroSchema::RecordAndDataConsolidation
    include Dry::Initializer[undefined: false].define -> do
      param :esploro_record, EsploroSchema::Types.Instance(::EsploroSchema::Elements::EsploroRecord)
    end

    def initialize(...)
      super

      @esploro_data = esploro_record.data || EsploroSchema::Elements::Data.new

      derive_all_properties!
    end

    private

    # @return [EsploroSchema::Elements::EsploroData]
    attr_reader :esploro_data

    class << self
      # @param [String, EsploroSchema::Elements::EsploroRecord] input
      # @return [EsploroSchema::Record]
      def parse(input)
        esploro_record = parse_record(input)

        new(esploro_record)
      end

      private

      # @param [String, EsploroSchema::Elements::EsploroRecord] input
      # @return [EsploroSchema::Elements::EsploroRecord]
      def parse_record(input)
        case input
        when EsploroSchema::Elements::EsploroRecord
          input
        when String
          EsploroSchema::Elements::EsploroRecord.from_xml(input)
        when nil
          EsploroSchema::Elements::EsploroRecord.new
        else
          # simplecov:disable
          raise ArgumentError, "Unsupported input for esploro record: #{input.inspect}"
          # simplecov:enable
        end
      end
    end
  end
end
