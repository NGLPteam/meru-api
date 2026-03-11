# frozen_string_literal: true

module Harvesting
  module Testing
    # Types for testing harvesting infrastructure.
    module Types
      extend ::Support::Typespace

      EsploroRecord = Instance(::EsploroSchema::Record)

      Identifier = Coercible::String.constrained(filled: true)

      JATSArticle = Instance(::Niso::Jats::Article)

      LIMIT_MIN = 10
      LIMIT_MAX = 100
      LIMIT_DEFAULT = 50

      Limit = Coercible::Integer.default(LIMIT_DEFAULT).constrained(gteq: LIMIT_MIN, lteq: LIMIT_MAX).fallback(LIMIT_DEFAULT)

      MetadataFormat = Instance(::HarvestMetadataFormat)

      OAIDCRoot = Instance(::Metadata::OAIDC::Root)

      OAIRecordKlass = Inherits(::Harvesting::Testing::OAI::SampleRecord)

      OAIResumptiontoken = Instance(::OAI::Provider::ResumptionToken)

      OAISetSpec = Coercible::String.constrained(filled: true)

      OAISetSpecs = Coercible::Array.of(OAISetSpec)

      Protocol = Instance(::HarvestProtocol)
    end
  end
end
