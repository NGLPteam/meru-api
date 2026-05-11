# frozen_string_literal: true

module Harvesting
  module Testing
    module OAI
      class EsploroRecord < ::ApplicationFrozenRecord
        include Harvesting::Testing::OAI::SampleRecord

        record_schema!("esploro") do
          required(:esploro).value(:esploro_record)
        end

        calculates! :esploro do |record|
          EsploroSchema::Record.parse record["metadata_source"]
        end
      end
    end
  end
end
