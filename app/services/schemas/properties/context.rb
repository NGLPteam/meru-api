# frozen_string_literal: true

module Schemas
  module Properties
    # A context used for reading values and also produced by {Schemas::Properties::WriteContext}
    # to persist the values with {Schemas::Instances::ApplyValueContext}.
    #
    # @see Types::SchemaInstanceContextType
    class Context
      include Dry::Core::Constants
      include Dry::Initializer[undefined: false].define -> do
        option :version, Schemas::Types::Version.optional, optional: true
        option :instance, Schemas::Types::Entity.optional, optional: true

        option :type_mapping, Schemas::Properties::TypeMapping::Type, default: proc { version&.type_mapping || Schemas::Properties::TypeMapping.new }

        option :values, Schemas::Types::ValueHash, default: proc { EMPTY_HASH }
        option :full_texts, FullText::Types::Map, default: proc { EMPTY_HASH }
        option :collected_references, Schemas::References::Types::CollectedMap, default: proc { EMPTY_HASH }
        option :scalar_references, Schemas::References::Types::ScalarMap, default: proc { EMPTY_HASH }
      end

      delegate :has_any_types?, :has_contributors?, :has_type?, to: :type_mapping

      # @return [Hash]
      attr_reader :current_values

      # @return [Hash]
      attr_reader :default_values

      # @return [Hash]
      attr_reader :field_values

      # @api private
      # @return [::Support::PropertyHash]
      attr_reader :known_values

      def initialize(...)
        super

        @known_values = filter_values.freeze

        @current_values = calculate_current_values.freeze

        @default_values = EMPTY_HASH

        @field_values = calculate_field_values.freeze
      end

      # @param [String] path
      # @return [<ApplicationRecord>]
      def collected_reference(path) = collected_references.fetch(path, EMPTY_ARRAY)

      # @param [String] path
      # @return [SchematicText, nil]
      def full_text(path) = full_texts[path]

      # @param [String] path
      # @return [ApplicationRecord, nil]
      def scalar_reference(path) = scalar_references[path]

      # @param [String] path
      # @return [Object, nil]
      def value_at(path) = known_values[path]

      private

      # @return [Hash]
      def calculate_current_values
        property_hash = known_values.dup

        property_hash.merge! collected_references
        property_hash.merge! scalar_references
        property_hash.merge! full_texts

        property_hash.to_h
      end

      # @return [Hash]
      def calculate_field_values
        property_hash = known_values.dup

        encoded_collections = collected_references.transform_values do |value|
          value.map(&:to_encoded_id)
        end

        encoded_scalars = scalar_references.transform_values do |value|
          value&.to_encoded_id
        end

        property_hash.merge! encoded_collections
        property_hash.merge! encoded_scalars
        property_hash.merge! full_texts

        property_hash.to_h
      end

      # @return [::Support::PropertyHash]
      def filter_values
        ::Support::PropertyHash.new(values).tap do |v|
          v.paths.each do |path|
            v.delete! path unless known_path?(path)
          end
        end
      end

      # @param [String] path
      def known_path?(path)
        paths = [path].tap do |p|
          p << path[/\A([^.]+)\./, 1] if ?..in?(path)
        end

        paths.any? { _1.in?(type_mapping.paths) }
      end
    end
  end
end
