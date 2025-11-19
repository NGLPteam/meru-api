# frozen_string_literal: true

module System
  class ShutdownWorkerJob < ApplicationJob
    queue_as :default

    queue_with_priority(-10_000)

    # @return [void]
    def perform
      GOOD_JOB_KEEP_RUNNING.make_false
    end
  end
end
