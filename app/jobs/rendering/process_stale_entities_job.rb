# frozen_string_literal: true

module Rendering
  # Iterate through all {StaleEntity} records and render their layouts.
  #
  # It will run for 2 minutes at max and then re-enqueue in order to cut
  # down on any potential deadlock scenarios.
  class ProcessStaleEntitiesJob < ApplicationJob
    include JobIteration::Iteration

    unique_job! by: :job

    self.job_iteration_max_job_runtime = 2.minutes

    queue_as :rendering

    # @param [String] before
    # @param [String] cursor
    # @return [void]
    def build_enumerator(before = Time.current.iso8601, cursor:)
      enumerator_builder.active_record_on_records(
        StaleEntity.stale(before:),
        cursor:
      )
    end

    # @param [StaleEntity] stale_entity
    # @param [String] _before
    # @return [void]
    def each_iteration(stale_entity, _before = Time.current.iso8601)
      stale_entity.process!
    end
  end
end
