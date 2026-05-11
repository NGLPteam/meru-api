# frozen_string_literal: true

module Harvesting
  module Testing
    module OAI
      class JATSRecord < ::ApplicationFrozenRecord
        include Harvesting::Testing::OAI::SampleRecord

        record_schema!("jats") do
          required(:article).value(:jats_article)
        end

        calculates! :article do |record|
          Niso::Jats::Article.from_xml(record["metadata_source"])
        end
      end
    end
  end
end
