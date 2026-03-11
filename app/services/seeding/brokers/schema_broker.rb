# frozen_string_literal: true

module Seeding
  module Brokers
    # This class defines how we import and export a specific {SchemaDefinition},
    # based on its declaration.
    class SchemaBroker
      include Dry::Core::Equalizer.new(:declaration)
      include Dry::Initializer[undefined: false].define -> do
        param :declaration, Seeding::Types::SchemaDeclaration

        option :suppressed_properties, Schemas::Properties::Types::FullPathList, default: proc { [] }

        option :namespace, Seeding::Types::SchemaNamespace, default: proc { declaration }
        option :identifier, Seeding::Types::SchemaIdentifier, default: proc { declaration }
      end

      include ::Support::Typing

      map_type! key: Seeding::Types::SchemaDeclaration

      def extract_properties(entity)
        Seeding::Export::SchemaPropertiesExporter.new(self, entity).call
      end

      # @param [SchemaVersion] schema_version
      def supported?(schema_version)
        schema_version.namespace == namespace && schema_version.identifier == identifier
      end

      # @param [#to_s] property
      def suppressed?(property)
        property.in? suppressed_properties
      end
    end
  end
end
