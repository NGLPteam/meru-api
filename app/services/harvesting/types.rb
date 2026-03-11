# frozen_string_literal: true

module Harvesting
  module Types
    extend ::Support::Typespace

    VALID_NAME = /\A([a-z_][a-zA-Z_0-9]*)\z/

    VALID_IDENTIFIER = /\A(?![_-])(?!.*[_-]{2,})[a-z0-9_-]{3,}(?<![_-])\z/

    VALID_PATH = /\A(?<part>[a-z_][a-zA-Z_0-9]*)\.\g<part>\z/

    # @see ::HarvestAttempt
    Attempt = ModelInstance("HarvestAttempt")

    Callable = Interface(:call)

    Configurable = Instance(::HarvestConfigurable)

    # @see ::HarvestConfiguration
    Configuration = ModelInstance("HarvestConfiguration")

    # Something that enforces an always-default hash
    EmptyDefaultHash = Coercible::Hash.default { {} }.fallback { {} }

    # @see ::HarvestEntity
    Entity = ModelInstance("HarvestEntity")

    # A simple pass-through identity function
    Identity = proc { _1 }

    Identifier = Coercible::Symbol.constrained(format: VALID_NAME)

    Identifiers = Array.of(Identifier)

    # @see ::HarvestMapping
    Mapping = ModelInstance("HarvestMapping")

    MaxRecordCount = Integer.constrained(gt: 0, lteq: Harvesting::ABSOLUTE_MAX_RECORD_COUNT).
      default(Harvesting::ABSOLUTE_MAX_RECORD_COUNT).
      fallback(Harvesting::ABSOLUTE_MAX_RECORD_COUNT)

    MessageLevel = ApplicationRecord.dry_pg_enum(:harvest_message_level)

    MessageLevelLimit = ApplicationRecord.dry_pg_enum(:harvest_message_level, default: "info").fallback("info")

    # @see HarvestMetadataFormat
    MetadataFormat = FrozenInstance("HarvestMetadataFormat")

    # @see HarvestMetadataFormat
    MetadataFormatName = ApplicationRecord.dry_pg_enum(:harvest_metadata_format)

    Path = Coercible::String.constrained(format: VALID_PATH) | Coercible::String.constrained(format: VALID_NAME)

    Paths = Coercible::Array.of(Path)

    # @see HarvestProtocol
    Protocol = FrozenInstance("HarvestProtocol")

    # @see HarvestProtocol
    ProtocolName = ApplicationRecord.dry_pg_enum(:harvest_protocol)

    # @see ::Types::HarvestPruneModeType
    PruneMode = ::Types::HarvestPruneModeType.dry_type.fallback("unmodified")

    # @see ::HarvestRecord
    Record = ModelInstance("HarvestRecord")

    # @see ::HarvestSet
    Set = ModelInstance("HarvestSet")

    # @see ::HarvestSource
    Source = ModelInstance("HarvestSource")

    SourceStatus = ApplicationRecord.dry_pg_enum(:harvest_source_status, default: "inactive").fallback(:inactive)

    # @see ::HarvestTarget
    Target = Instance(::HarvestTarget)

    Attemptable = Source | Mapping

    # Any dry type
    Type = Instance(Dry::Types::Type)

    UnderlyingDataFormat = Coercible::String.enum("xml", "json")

    # A valid URL string
    URL = String.constrained(format: /\A#{Support::GlobalTypes::URL_PATTERN}\z/)

    # An XML document, ideally well-formed
    XMLDocument = Instance Nokogiri::XML::Document

    # A single XML element
    XMLElement = Instance Nokogiri::XML::Element

    # An XML document fragment
    XMLFragment = Instance Nokogiri::XML::DocumentFragment

    # A magic string type that will try to look up provided values
    # in {Harvesting::Metadata::Namespaces}, otherwise it expects
    # any provided values to be strings. We do not make assumptions
    # that they have to be a URI.
    XMLNamespace = String.constructor do |value|
      Harvesting::Metadata::Namespaces.then do |container|
        container.key?(value) ? container[value] : value
      end
    end

    # A mapping of XML namespaces. It expects keys to be symbols (or strings coerced to symbols)
    # and values to be {XMLNamespace}.
    #
    # Once coerced, this can be provided as namespaces to Nokogiri's `at_xpath`, `xpath`, etc methods.
    XMLNamespaceMap = Hash.map(Coercible::Symbol.optional, XMLNamespace)

    # The actual method to use for parsing XML strings with Nokogiri.
    #
    # @see XMLParseType
    XMLParseMethod = Symbol.default(:parse).enum(:parse, :fragment).constructor do |value|
      value.to_s.gsub(/\Adocument\z/, "parse").to_sym.presence
    end

    # We might be parsing a document or a fragment.
    XMLParseType = Coercible::Symbol.default(:document).enum(:document, :fragment).fallback(:document)

    # A string of XML
    XMLString = Coercible::String

    # Any valid XML input for parsing.
    XMLInput = XMLDocument | XMLFragment | XMLString
  end
end
