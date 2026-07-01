# frozen_string_literal: true

module Schemas
  module Static
    module Namespaced
      extend ActiveSupport::Concern

      include Schemas::Static::Constants

      BUILTIN_NAMESPACES = Schemas::Static::Constants::BUILTIN_NAMESPACES

      included do
        scope :by_namespace, ->(namespace) { where(namespace:) }
        scope :by_identifier, ->(identifier) { where(identifier:) }
        scope :by_tuple, ->(namespace, identifier) { by_namespace(namespace).by_identifier(identifier) }

        scope :builtin, -> { by_namespace(BUILTIN_NAMESPACES) }
        scope :custom, -> { where.not(namespace: BUILTIN_NAMESPACES) }

        scope :non_default, -> { where.not(namespace: %w[default testing]) }
      end

      def builtin?
        namespace.in?(BUILTIN_NAMESPACES)
      end

      def custom?
        namespace? && !builtin?
      end

      # @return [StaticSchemaDefinition] if {#builtin?} and {SchemaDefinition}
      # @return [StaticSchemaVersion] if {#builtin?} and {SchemaVersion}
      # @return [nil] unless {#builtin?}
      def static_record
        # simplecov:disable
        return unless builtin? && !testing?

        case self
        in ::SchemaDefinition
          ::StaticSchemaDefinition.find(declaration)
        in ::SchemaVersion
          ::StaticSchemaVersion.find(declaration)
        end
        # simplecov:enable
      end

      def testing?
        namespace == "testing"
      end
    end
  end
end
