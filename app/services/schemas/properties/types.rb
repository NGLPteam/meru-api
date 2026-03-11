# frozen_string_literal: true

module Schemas
  module Properties
    # Types specific to working with schema property classes.
    module Types
      extend ::Support::Typespace

      # @api private
      #
      # @see Function
      KNOWN_FUNCTIONS = %w[content metadata presentation sorting unspecified].freeze

      private_constant :KNOWN_FUNCTIONS

      HypertextURL = String.constrained(http_uri: true)

      DEFAULT_URL_LABEL = "URL"

      # The shape of the object that backs a `URL` schema property.
      #
      # @see Schemas::Properties::Scalar::URL
      URLShape = Hash.schema(
        href: HypertextURL,
        label: String.default(DEFAULT_URL_LABEL),
        title?: String.default("").optional,
      ).with_key_transform(&:to_sym)

      NormalizedURL = URLShape.constructor do |value|
        case value
        when Schemas::Properties::Types::URLShape
          Schemas::Properties::Types::URLShape[value]
        when HypertextURL
          { href: value, label: DEFAULT_URL_LABEL }
        end
      end

      Registry = Dry::Schema::TypeContainer.new

      Registry.register "params.collected_reference", Schemas::References::Types::Collected

      Registry.register "params.scalar_reference", Schemas::References::Types::Scalar

      Registry.register "params.full_text", FullText::Types::NormalizedReference

      Registry.register "params.variable_date", VariablePrecisionDate::ParseType

      Registry.register "params.url", URLShape

      SCALAR_TYPES = %w[
        asset
        assets
        boolean
        contributor
        contributors
        controlled_vocabulary
        controlled_vocabularies
        date
        email
        entities
        entity
        float
        full_text
        integer
        markdown
        multiselect
        select
        string
        tags
        timestamp
        url
        variable_date
      ].freeze

      OTHER_TYPES = %w[group unknown].freeze

      KNOWN_TYPES = (SCALAR_TYPES | OTHER_TYPES).sort.freeze

      # An individual component of a property path. Matches the format
      # expressed in the metaschema, and requires something that more
      # or less resembles valid ruby property names (sans `!` / `?`).
      PATH_PART = /[a-z][a-z0-9_]*[a-z]/

      # A full path, composed of {PATH_PART} with an optional group key
      # preceding it.
      FULL_PATH = /#{PATH_PART}(?:\.#{PATH_PART})?/

      # The path used to build type maps.
      TYPE_PATH = /\A(?<full_path>#{FULL_PATH})\.\$type\z/

      # A meta type for matching dry-types, used to enforce setting a base type
      # within scalar property classes.
      #
      # @see Schemas::Properties::Scalar::Base.base_type
      BaseType = Nominal(Dry::Types::Type).constructor do |value|
        case value
        when :any then Any
        when :boolean then Params::Bool
        when Dry::Types::Type then value
        when PossibleParamTypeName then Registry["params.#{value}"]
        end
      end

      # A type for matching the full path for a property
      #
      # @see FULL_PATH
      FullPath = String.constrained(format: /\A#{FULL_PATH}\z/)

      # A type for matching a list of paths
      #
      # @see FullPath
      FullPathList = Coercible::Array.of(FullPath)

      # A defined function for the property.
      Function = String.enum(*KNOWN_FUNCTIONS)

      # A logical grouping for the kind of property.
      #
      # There's an associated enum type in the database: `schema_property_kind`.
      Kind = KindName = ApplicationRecord.dry_pg_enum(:schema_property_kind)

      # @api private
      #
      # An enum type that matches the name of any default `dry-types` Params type.
      PossibleParamTypeName = Registry.keys.grep(/\Aparams\./).then do |types|
        unprefixed_types = types.map { |type| type.sub(/\Aparams\./, "") }

        Coercible::String.enum(*unprefixed_types)
      end

      # A meta type for matching the _schema_ type used by scalar properties
      # when validating within contracts.
      #
      # @see Schemas::Properties::Scalar::Base.base_type
      SchemaType = Instance(Dry::Types::Type) | String | Symbol

      # A known schema property type name.
      TypeName = ApplicationRecord.dry_pg_enum(:schema_property_type, default: "unknown")

      # A key for a type mapping
      # @see Schemas::Properties::TypeMapping
      TypeKey = String.constrained(format: TYPE_PATH)

      # A mapping from a property configuration
      #
      # @see Schemas::Properties::TypeMapping
      TypeMap = Hash.map(TypeKey, TypeName)

      # A set of types
      #
      # @see Schemas::Properties::TypeMapping
      TypeSet = Coercible::Array.of(TypeName)
    end
  end
end
