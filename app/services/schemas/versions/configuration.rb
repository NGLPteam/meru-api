# frozen_string_literal: true

module Schemas
  module Versions
    # This object centralizes the bulk of the logic and settings for a {SchemaVersion}.
    class Configuration
      include StoreModel::Model
      include Schemas::Properties::CompilesToSchema

      # A set of {#identifier identifiers} can be contained within a logical
      # grouping of a namespace.
      #
      # @return [String]
      attribute :namespace, :string

      # A unique identifier within the {#namespace} for this schema,
      # used to determine which {SchemaDefinition} it belongs to.
      attribute :identifier, :string

      # A human-readable name for the schema.
      #
      # @return [String]
      attribute :name, :string

      # The kind of entity this schema applies to
      #
      # @return ["community", "collection", "item"]
      attribute :kind, :string

      # The specific (semantic) version number of this schema.
      #
      # @return [Semantic::Version]
      attribute :version, :semantic_version

      # A collection of named ancestors that the schema should implement.
      #
      # @return [<Schemas::Associations::NamedAncestor>]
      attribute :ancestors, Schemas::Associations::NamedAncestor.to_array_type, default: proc { [] }

      # A collection of constraints to describe what schema(s) the immediate parent of an entity can be.
      #
      # @note Multiple entries in this list signify `A OR B OR C`
      # @return [<Schemas::Associations::Parent>]
      attribute :parents, Schemas::Associations::Parent.to_array_type, default: proc { [] }

      # A collection of constraints to describe what schema(s) the immediate children of an entity can be.
      #
      # @note Multiple entries in this list signify `A OR B OR C`
      # @return [<Schemas::Associations::Child>]
      attribute :children, Schemas::Associations::Child.to_array_type, default: proc { [] }

      # Configurations for core properties on schema instances.
      #
      # @return [Schemas::Versions::CoreDefinition]
      attribute :core, Schemas::Versions::CoreDefinition.to_type, default: proc { {} }

      # A collection of definitions that dictate the default dynamic {::Ordering orderings} an entity
      # that implements this schema can have.
      #
      # @return [<Schemas::Orderings::Definition>]
      attribute :orderings, Schemas::Orderings::Definition.to_array_type, default: proc { [] }

      # The list of properties this schema defines.
      #
      # @note This list is deterministically ordered.
      # @return [<Schemas::Properties::GroupDefinition, Schemas::Properties::Scalar::Base>]
      attribute :properties, Schemas::Properties::Definition.to_array_type, default: proc { [] }

      # Configurations for handling rendering schema instances in isolation, outside of an {Ordering}.
      #
      # @return [Schemas::Versions::RenderDefinition]
      attribute :render, Schemas::Versions::RenderDefinition.to_type, default: proc { {} }

      # A collection of configurations for what kinds of {Submission submissions} can be made to an entity that implements this schema.
      #
      # @return [<Schemas::Associations::Submission>]
      attribute :submissions, Schemas::Associations::Submission.to_array_type, default: proc { [] }

      validates :kind, inclusion: { in: %w[community collection item] }

      validates :version, :namespace, :identifier, :name, presence: true

      validates :ancestors, :orderings, :properties, store_model: true, unique_items: true

      # @!attribute [r] declaration
      # A combination of the {#namespace}, {#identifier}, and {#version}.
      #
      # This is a generated attribute in the database, but is implemented here
      # for Ruby-only comparisons and data fetching.
      # @return [String]
      def declaration
        "#{namespace}:#{identifier}:#{version}"
      end

      # Iterate over each {#properties property} (and subproperty, in the case of groups).
      #
      # @param [Boolean] include_groups Whether to include {Schemas::Properties::GroupDefinition groups} themselves
      #   when iterating—useful if you need information for the group beyond its subproperties.
      # @yield [prop]
      # @yieldparam [Schemas::Properties::GroupDefinition, Schemas::Properties::Scalar::Base] prop
      # @return [Enumerator]
      def each_property(include_groups: false)
        return enum_for(__method__, include_groups:) unless block_given?

        recur_props = ->(prop) do
          if prop.group?
            yield prop if include_groups

            prop.properties.each(&recur_props)
          else
            yield prop
          end
        end

        properties.each(&recur_props)
      end

      # Check to see if the configuration has a specific {#orderings ordering}.
      # @param [#to_s] identifier
      def has_ordering?(identifier)
        id = identifier.to_s

        orderings.any? do |ordering|
          ordering.id == id
        end
      end

      # @param [#to_s] identifier
      # @return [Schemas::Orderings::Definition, nil]
      def ordering_definition_for(identifier)
        id = identifier.to_s

        orderings.detect do |ordering|
          ordering.id == id
        end
      end

      # @param [String] full_path
      # @return [Schemas::Properties::GroupDefinition, Schemas::Properties::ScalarDefinition, nil]
      def property_for(full_path)
        find_prop = ->(prop) do
          throw :found, prop if prop.full_path == full_path

          next unless prop.group?

          next unless full_path.starts_with? prop.prefix

          prop.properties.each(&find_prop)
        end

        catch(:found) do
          properties.each(&find_prop)

          nil
        end
      end

      # Extract the paths for all scalar properties based on an optional filter block.
      #
      # @yield [prop] Optionally filter the property.
      # @yieldparam [Schemas::Properties::Scalar::Base] prop
      # @yieldreturn [Boolean] whether the prop's full path should be included
      # @return [<String>]
      def property_paths
        build_paths = ->(prop, paths) do
          if prop.group?
            prop.properties.each_with_object(paths, &build_paths)
          else
            next if block_given? && !yield(prop)

            paths << prop.full_path
          end
        end

        properties.each_with_object([], &build_paths)
      end

      # Retrieve a list of all paths for properties that are {Schemas::Properties::References::Collected a collected reference}.
      #
      # @return [<String>]
      def collected_reference_paths
        property_paths do |prop|
          prop.kind_of?(Schemas::Properties::References::Collected)
        end
      end

      # Retrieve a list of all paths for properties that are {Schemas::Properties::References::Scalar a scalar reference}.
      #
      # @return [<String>]
      def scalar_reference_paths
        property_paths do |prop|
          prop.kind_of?(Schemas::Properties::References::Scalar)
        end
      end

      # Retrieve a list of all paths for {Schemas::Properties::Scalar::FullText full-text properties}.
      #
      # @return [<String>]
      def text_reference_paths
        property_paths do |prop|
          prop.kind_of?(Schemas::Properties::Scalar::FullText)
        end
      end

      # {Schemas::Properties::CompileContract Compile} a contract.
      #
      # @return [Dry::Validation::Contract]
      def to_contract
        MeruAPI::Container["schemas.properties.compile_contract"].call(properties)
      end

      # Retrieve a list of hashes suitable for upserting into {SchemaVersionProperty}.
      #
      # @api private
      # @return [<{ Symbol => Object }>]
      def to_version_properties
        each_property(include_groups: true).with_index.map do |property, index|
          property.to_version_property.merge(position: index + 1)
        end
      end

      # @return [Schemas::Properties::TypeMapping]
      def type_mapping
        map = {}
        paths = SortedSet.new
        set = SortedSet.new

        each_property include_groups: true do |prop, h|
          type_path = "#{prop.full_path}.$type"

          type = prop.type.to_s

          map[type_path] = type

          paths << prop.full_path

          set << type
        end

        Schemas::Properties::TypeMapping.new map, paths:, set:
      end
    end
  end
end
