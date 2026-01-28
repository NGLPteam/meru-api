# frozen_string_literal: true

module System
  # This job runs the {System::Checker} to perform system integrity checks.
  # It runs frequently as a maintenance task.
  #
  # @see System::Check
  # @see System::Checker
  class CheckJob < ApplicationJob
    queue_as :maintenance

    unique_job! by: :job

    # @return [void]
    def perform
      call_operation!("system.check")
    end
  end
end
