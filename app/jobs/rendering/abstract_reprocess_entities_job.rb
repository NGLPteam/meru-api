# frozen_string_literal: true

module Rendering
  # @abstract
  # Enqueues reprocessing jobs for all entities of a given class.
  # @see Entities::ReprocessLayoutsJob
  class AbstractReprocessEntitiesJob < ApplicationJob
    extend Dry::Core::ClassAttributes

    include JobIteration::Iteration

    defines :entity_klass, type: Support::Types::Class

    entity_klass ApplicationRecord

    good_job_control_concurrency_with(
      total_limit: 1,
      key: -> { "#{self.class.name}-#{queue_name}" }
    )

    queue_as :default

    # @param [String] cursor
    # @return [void]
    def build_enumerator(cursor:)
      enumerator_builder.active_record_on_records(
        self.class.entity_klass.all,
        cursor:
      )
    end

    # @see Entities::ReprocessLayoutsJob
    # @param [HierarchicalEntity] entity
    # @return [void]
    def each_iteration(entity)
      Entities::ReprocessLayoutsJob.perform_later(entity)
    end
  end
end
