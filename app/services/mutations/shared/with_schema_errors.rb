# frozen_string_literal: true

module Mutations
  module Shared
    # Methods for handling applying schema properties and exposing
    # the validation errors (if any) to the GraphQL API.
    #
    # @see Schemas::Instances::Apply
    module WithSchemaErrors
      extend ActiveSupport::Concern

      include Mutations::Shared::AttachesPolymorphicEntity

      included do
        include MeruAPI::Deps[apply: "schemas.instances.apply"]

        before_prepare :prepare_schema_errors!
      end

      # @see Schemas::Instances::Apply
      # @see #with_applied_schema_values!
      # @param [HierarchicalEntity] entity
      # @param [Hash] properties
      # @return [void]
      def apply_schema_properties!(entity, properties)
        application = apply.call entity, properties

        with_applied_schema_values! application do |applied_entity|
          attach_polymorphic_entity! applied_entity
        end
      end

      # Given the application of schema properties, either fail or yield the
      # entity with newly-applied properties to a provided block.
      #
      # @param [Dry::Monads::Result] application
      #   the result from {Schemas::Instances::Apply}
      # @yield [applied_entity] On a successful application,
      #   the entity with newly-applied properties will be yielded
      # @yieldparam [HierarchicalEntity] applied_entity
      # @yieldreturn [void]
      # @return [void]
      def with_applied_schema_values!(application)
        with_result! application do |m|
          m.success do |applied_entity|
            yield applied_entity
          end

          m.failure(:invalid_values) do |_, result|
            add_schema_errors! result

            throw_invalid
          end

          m.failure do |*reasons|
            # simplecov:disable
            Failure[*reasons]

            throw_invalid
            # simplecov:enable
          end
        end
      end

      # @api private
      # @param [Dry::Validation::Result] result
      # @return [void]
      def add_schema_errors!(result)
        result.errors.each do |error|
          path = error.path.join(?.).presence

          if path.blank? || /\Abase\z/.match?(path)
            add_global_error! error.text
          else
            graphql_response[:schema_errors] << to_schema_error(error)
          end
        end
      end

      # @api private
      # @param [Dry::Schema::Message, Dry::Schema::Hint, Dry::Validation::Message] error
      # @return [{ Symbol => Object }]
      def to_schema_error(error)
        {}.tap do |h|
          h[:hint] = error.hint?
          h[:path] = error.path.join(?.)
          h[:base] = false
          h[:message] = error.text
          h[:metadata] = error.meta
        end
      end

      # @api private
      # @return [void]
      def prepare_schema_errors!
        graphql_response[:schema_errors] = []
      end
    end
  end
end
