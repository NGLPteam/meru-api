# frozen_string_literal: true

module CacheWarmers
  # @see CacheWarmer
  # @see CacheWarmers::Run
  # @see CacheWarmers::Runner
  class RunJob < ApplicationJob
    queue_as :default

    queue_with_priority 800

    unique_job! by: :first_arg

    # @return [void]
    def perform(cache_warmer)
      call_operation!("cache_warmers.run", cache_warmer)
    end
  end
end
