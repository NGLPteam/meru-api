# frozen_string_literal: true

module Schemas
  # Types that are shared across the entire schema ecosystem.
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    # The supported format. Alphanumeric with underscores, all lowercase.
    #
    # @see Component
    COMPONENT_FORMAT = /\A[a-z][a-z0-9_]*?[a-z0-9]\z/

    # A pattern to match a semantic version.
    #
    # @api private
    SEMVER_PATTERN = Regexp.new("(?<semver>#{Semantic::Version::SemVerRegexp.source[2...-2]})").freeze

    # A pattern to represent a signifier for a version. It can either by a semantic version or the literal `latest`,
    # which has a special meaning in certain services.
    SIGNIFIER_PATTERN = Regexp.new("(?:#{SEMVER_PATTERN}|latest)").freeze

    # A pattern for matching a fully-qualified schema declaration with an optional version signifier.
    #
    # @note This pattern also supports both `namespace.identifier` and `namespace:identifier` usages.
    FLEXIBLE_DECLARATION_PATTERN = /\A(?<namespace>[a-z_]+)[.:](?<identifier>[a-z_0-9]+)(?::(?<version>#{SIGNIFIER_PATTERN}))?\z/

    # A pattern for matching a fully-qualified schema definition.
    #
    # @note This pattern supports only `namespace:identifier` usage.
    DECLARATION_PATTERN = /\A(?<namespace>[a-z_]+):(?<identifier>[a-z_0-9]+)\z/

    # A pattern for matching a fully-qualified schema declaration with a required version string
    #
    # @note This pattern supports only `namespace:identifier` usage.
    VERSION_DECLARATION_PATTERN = /\A(?<namespace>[a-z_]+):(?<identifier>[a-z_0-9]+):(?<version>[^:\s]+)\z/

    # A name of a component within a schema. Identifiers, namespaces, ordering names, etc.
    #
    # @see COMPONENT_FORMAT
    Component = Coercible::String.constrained(format: COMPONENT_FORMAT)

    # A type for matching a fully-qualified schema declaration.
    #
    # It will use {FLEXIBLE_DECLARATION_PATTERN} to match a more lax approach that includes
    # an optional schema version, and it will finesse it into the proper declaration format.
    #
    # @see DECLARATION_PATTERN
    Declaration = String.constrained(format: DECLARATION_PATTERN).constructor do |value|
      case value
      when FLEXIBLE_DECLARATION_PATTERN
        "#{Regexp.last_match[:namespace]}:#{Regexp.last_match[:identifier]}"
      when SchemaVersion
        value.schema_definition.declaration
      when SchemaDefinition
        value.declaration
      else
        value
      end
    end

    HasSchemaVersion = Interface(:schema_version)

    SchemaInstance = Instance(::Community) | Instance(::Collection) | Instance(::Item)

    ChildAssociation = Symbol.enum(:collections, :children, :items)

    NullifiableAssociation = Symbol.enum(:parent)

    ParentAssociation = Symbol.enum(:community, :parent, :collection)

    ParentInheritableAssociation = Symbol.enum(:community, :collection)

    Kind = Coercible::String.enum("community", "collection", "item").constructor do |value|
      case value
      when SchemaDefinition, SchemaVersion, Schemas::Versions::Configuration
        value.kind
      when ::Community, ::Collection, ::Item, ::Entity
        value.schema_kind
      else
        value
      end
    end

    Ordering = ModelInstance("Ordering")

    # A type that matches either a scalar property or a property group.
    #
    # @see Schemas::Properties::GroupDefinition
    # @see Schemas::Properties::Scalar::Base
    Property = Instance(Schemas::Properties::Scalar::Base) | Instance(Schemas::Properties::GroupDefinition)

    # A list of property instances.
    #
    # @see Property
    PropertyList = Array.of(Property)

    SemanticVersion = Constructor(Semantic::Version) do |input|
      # :nocov:
      raise Dry::Types::ConstraintError.new(nil, input) if input.blank?

      Semantic::Version.new input.to_s
    rescue ArgumentError => e
      raise Dry::Types::ConstraintError.new e.message, input
      # :nocov:
    end

    ValueHash = Instance(ActiveSupport::HashWithIndifferentAccess).constructor do |value|
      maybe_value = value.respond_to?(:to_h) ? value.to_h : value

      maybe_hash = Coercible::Hash.try maybe_value

      maybe_hash.to_monad.value_or({}).with_indifferent_access
    end

    Version = ModelInstance("SchemaVersion")

    # A type for matching a fully qualified, versioned schema declaration.
    VersionDeclaration = String.constrained(format: VERSION_DECLARATION_PATTERN).constructor do |value|
      case value
      when SchemaVersion then value.declaration
      else
        value
      end
    end
  end
end
