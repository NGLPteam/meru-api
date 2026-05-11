# frozen_string_literal: true

module Harvesting
  module Testing
    module OAI
      class OAIDCRecord < ::ApplicationFrozenRecord
        include Harvesting::Testing::OAI::SampleRecord

        record_schema!("oaidc") do
          required(:root).value(:oaidc_root)
        end

        calculates! :root do |record|
          ::Metadata::OAIDC::Root.from_xml(record["metadata_source"])
        end
      end
    end
  end
end
