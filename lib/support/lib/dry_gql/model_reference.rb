# frozen_string_literal: true

module Support
  module DryGQL
    # A lazily-evaluated reference to a model that can be used to evaluate and fetch
    # details about how the model is used within the application's GraphQL API.
    class ModelReference < ::Support::Models::Reference
      option :container, ::Support::DryGQL::TypeContainer::Type

      option :as_type, Types::TypeReference.optional, optional: true, as: :provided_type

      option :single_key, Types::ModelKey, default: -> { model_name.singular }

      option :plural_key, Types::ModelKey, default: -> { model_name.plural }

      option :reference_key, Types::ModelKey, default: -> { single_key }

      # @!attribute [r] as_type
      # The GraphQL type to use for this model reference, which can be a string to lazily load the type from the container, or an actual GraphQL type.
      #
      # It will attempt to derive the type from the model if it can.
      #
      # @return [GraphQL::Schema::Member, String]
      def as_type
        @as_type or realized!
      end

      # @!attribute [r] single_type
      # A dry type representing a single instance of the referenced model.
      #
      # @return [Support::DryGQL::Types::Type]
      def single_type
        @single_type or realized!
      end

      # @!attribute [r] plural_type
      # A dry type representing an array of instances of the referenced model.
      #
      # @return [Support::DryGQL::Types::Type]
      def plural_type
        @plural_type or realized!
      end

      private

      def realization
        super

        @as_type = provided_type || klass.graphql_node_type_name
        @single_type = fetch_single_type
        @plural_type = fetch_plural_type
      end

      def fetch_single_type
        ::Support::DryGQL::Types.Instance(@klass).gql_loads(@as_type).gql_description(<<~TEXT)
        Filter by a single #{@klass}.
        TEXT
      end

      def fetch_plural_type
        Types::Array.of(@single_type).gql_loads(@as_type).gql_description(<<~TEXT)
        Filter by multiple #{@klass}.
        TEXT
      end
    end
  end
end
