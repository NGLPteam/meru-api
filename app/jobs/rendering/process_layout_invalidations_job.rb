# frozen_string_literal: true

module Rendering
  # Iterate through all {LayoutInvalidation} that are marked as stale
  # and revalidate them in a serial fashion in order to avoid blowing
  # up the database during high concurrency periods. The re-rendering
  # of layouts and templates is never urgent.
  class ProcessLayoutInvalidationsJob < ApplicationJob
    include JobIteration::Iteration

    good_job_control_concurrency_with(
      total_limit: 1,
      key: "Rendering::ProcessLayoutInvalidationsJob"
    )

    queue_as :rendering

    # @param [String] before
    # @param [String] cursor
    # @return [void]
    def build_enumerator(before = Time.current.iso8601, cursor:)
      enumerator_builder.active_record_on_records(
        LayoutInvalidation.stale(before:),
        cursor:
      )
    end

    # @param [LayoutInvalidation] layout_invalidation
    # @param [String] _before
    # @return [void]
    def each_iteration(layout_invalidation, _before = Time.current.iso8601)
      layout_invalidation.process!
    end
  end
end
