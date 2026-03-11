# frozen_string_literal: true

module Harvesting
  module Metadata
    module Types
      include Dry::Core::Constants
      extend ::Support::Typespace

      ContributionProxy = ::Harvesting::Contributions::Proxy::Type

      ContributionProxies = Coercible::Array.of(ContributionProxy)

      HarvestRecord = ModelInstance("HarvestRecord")

      HasContent = Interface(:content)

      # @see HarvestMetadataMapping
      MetadataMappingPattern = Coercible::String

      # @see HarvestMetadataMapping
      MetadataMappingPatterns = Coercible::Array.of(MetadataMappingPattern).default(EMPTY_ARRAY).constructor do |value|
        value.nil? || value == Dry::Types::Undefined ? Dry::Types::Undefined : Coercible::Array.of(MetadataMappingPattern)[value].compact_blank.uniq
      end

      # @see HarvestMetadataMapping
      MetadataMappingsMatch = Coercible::Hash.schema(
        identifier?: MetadataMappingPatterns,
        relation?: MetadataMappingPatterns,
        title?: MetadataMappingPatterns
      ).with_key_transform(&:to_sym)

      SafeBoolean = Params::Bool.fallback(false)

      Tag = Coercible::String

      TagList = Coercible::Array.of(Coercible::String)

      # A valid URL string
      URL = String.constrained(http_uri: true)

      # This remaps certain simple types in {Harvesting::Metadata::TypeRegistry}
      # to use param coercion and other type-safety / coercion features.
      #
      # Booleans will always bool, ints will always coerce, etc.
      REGISTERED_TYPE_LOOKUP_MAP = {
        bool: "safe_boolean",
        boolean: "safe_boolean",
        date: "params.date",
        str: "params.string",
        string: "params.string",
        int: "params.integer",
        integer: "params.integer",
        float: "params.float",
        time: "params.time",
        timestamp: "params.time",
      }.with_indifferent_access.freeze

      private_constant :REGISTERED_TYPE_LOOKUP_MAP

      class << self
        # @see Harvesting::Metadata::TypeRegistry
        # @param [String, Symbol, Dry::Types::Type] name_or_type
        # @return [Dry::Types::Type]
        def registered_type_for(name_or_type)
          return name_or_type if name_or_type.kind_of?(Dry::Types::Type)

          key = REGISTERED_TYPE_LOOKUP_MAP.fetch name_or_type, name_or_type

          Harvesting::Metadata::TypeRegistry[key]
        end
      end
    end
  end
end
