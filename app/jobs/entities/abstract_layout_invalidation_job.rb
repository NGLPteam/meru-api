# frozen_string_literal: true

module Entities
  # @abstract
  class AbstractLayoutInvalidationJob < ApplicationJob
    extend Dry::Core::ClassAttributes

    include JobIteration::Iteration

    unique_job! by: :queue_first_id

    defines :entity_enumerator_klass, type: Entities::Types.Inherits(::Entities::Enumeration::Abstract)

    entity_enumerator_klass ::Entities::Enumeration::Null

    queue_as :invalidations

    # @param [HierarchicalEntity] source_entity
    # @param [String, nil] cursor
    # @return [void]
    def build_enumerator(source_entity, cursor:)
      enum = self.class.entity_enumerator_klass.(source_entity, cursor:)

      enumerator_builder.wrap(nil, enum)
    end

    # @param [HierarchicalEntity] entity
    # @param [HierarchicalEntity] _source_entity
    # @return [void]
    def each_iteration(entity, _source_entity)
      entity.invalidate_layouts!
    end
  end
end
