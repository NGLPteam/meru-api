# frozen_string_literal: true

module CacheWarmers
  # @see CacheWarmer
  # @see CacheWarmers::Run
  # @see CacheWarmers::Runner
  class RunJob < ApplicationJob
    queue_as :cache_warming

    unique_job! by: :first_arg

    # @return [void]
    def perform(cache_warmer)
      call_operation!("cache_warmers.run", cache_warmer)
    end
  end
end
