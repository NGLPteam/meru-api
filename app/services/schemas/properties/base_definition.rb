# frozen_string_literal: true

module Schemas
  module Properties
    # @abstract
    class BaseDefinition
      include Dry::Core::Memoizable
      include Dry::Monads[:result]
      include StoreModel::Model

      attribute :path, :string
      attribute :type, :string
      attribute :description, :string

      alias full_path path

      # A hook method used to attach the property to a dry-schema.
      #
      # @abstract
      # @param [Dry::Schema::DSL] context
      # @see Schemas::Properties::CompileSchema
      # @return [void]
      def add_to_schema!(context); end

      # A hook method used when compiling the property into a dry-validation contract.
      # It should solely be used for adding rules, as the type-checking is handled by
      # {#add_to_schema!}.
      #
      # @abstract
      # @param [Dry::Validation::Contract] context
      # @see Schemas::Properties::CompileContract
      # @return [void]
      def add_to_rules!(context); end

      # Whether or not the property is orderable
      def orderable?
        false
      end

      # @!attribute [r] key
      # Symbol version of {#path}.
      # @return [Symbol]
      def key
        path.to_sym
      end

      def array? = false

      def group? = type == "group"

      def nested? = false

      def required? = false

      def scalar? = type != "group"

      # @abstract
      def searchable? = false

      # @!attribute [r] kind
      # @return ["group", "reference", "complex", "simple"]
      def kind = group? ? "group" : "simple"

      def version_property_label = path.to_s.titleize

      def to_version_property
        {
          path: full_path,
          type:,
          kind:,
          label: version_property_label,
          extract_path: full_path.split(?.),
          array: array?,
          nested: nested?,
          orderable: orderable?,
          required: required?,
          metadata: to_version_property_metadata,
          function: 'unspecified',
          searchable: searchable?,
        }
      end

      def to_version_property_metadata
        {
          description: description.presence,
        }.compact
      end

      # A hook method for writing values to an entity
      #
      # @param [Schemas::Properties::WriteContext] context
      # @return [Dry::Monads::Result]
      def write_values_within!(context)
        Success nil
      end
    end
  end
end
