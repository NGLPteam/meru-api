# frozen_string_literal: true

module Schemas
  module Instances
    # Given a {HierarchicalEntity}, read its {SchemaVersion} for any {Schemas::Orderings::Definition ordering definitions}
    # and then try to create them.
    #
    # @operation
    class PopulateOrderings
      include Dry::Monads[:do, :result]
      include MeruAPI::Deps[reset_ordering: "schemas.orderings.reset"]

      # @param [HierarchicalEntity] entity
      # @param [Boolean] reset Run {Schemas::Orderings::Reset} on existing orderings
      # @return [Dry::Monads::Result]
      def call(entity, reset: false)
        entity.schema_version.configuration.orderings.each do |definition|
          yield populate_definition!(entity, definition, reset:)
        end

        Success nil
      end

      private

      # @param [HierarchicalEntity] entity
      # @param [Schemas::Ordering::Definition] definition
      # @param [Boolean] reset
      # @return [Dry::Monads::Success(void)]
      def populate_definition!(entity, definition, reset: false)
        ordering = Ordering.by_entity(entity).by_identifier(definition.id).first_or_initialize do |new_record|
          new_record.schema_version = entity.schema_version
          new_record.definition = definition
          new_record.schema_position = definition.schema_position
          new_record.position = definition.schema_position
          new_record.pristine = true
        end

        if ordering.persisted?
          return reset_ordering.call(ordering) if reset

          return Success()
        end

        ordering.save!

        Success()
      end
    end
  end
end
