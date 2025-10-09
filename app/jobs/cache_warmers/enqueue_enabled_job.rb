# frozen_string_literal: true

module CacheWarmers
  # Enqueue each enabled {CacheWarmer} with a {CacheWarmers::RunJob}.
  class EnqueueEnabledJob < ApplicationJob
    include JobIteration::Iteration

    good_job_control_concurrency_with(
      total_limit: 1,
      key: "CacheWarmers::EnqueueEnabledJob"
    )

    queue_as :maintenance

    # @param [String] cursor
    # @return [void]
    def build_enumerator(cursor:)
      enumerator_builder.active_record_on_records(
        CacheWarmer.enabled,
        cursor:
      )
    end

    # @see CacheWarmers::RunJob
    # @param [CacheWarmer] cache_warmer
    # @return [void]
    def each_iteration(cache_warmer)
      cache_warmer.run_asynchronously!
    end
  end
end
