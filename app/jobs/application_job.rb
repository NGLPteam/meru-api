# frozen_string_literal: true

# @abstract
class ApplicationJob < ActiveJob::Base
  extend Dry::Core::ClassAttributes

  # The extension must be included before other extensions
  include GoodJob::ActiveJobExtensions::InterruptErrors

  include GoodJob::ActiveJobExtensions::Concurrency

  JobTimeoutError = Class.new(StandardError)

  defines :max_runtime, type: Support::Types.Instance(ActiveSupport::Duration)

  max_runtime 10.minutes

  retry_on ActiveRecord::QueryCanceled

  retry_on JobTimeoutError, wait: :polynomially_longer, attempts: 10

  retry_on GoodJob::InterruptError, wait: :polynomially_longer, attempts: Float::INFINITY

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # This error is unlikely to resolve itself on subsequent executions.
  # :nocov:
  discard_on NameError unless Rails.env.test?
  # :nocov:

  around_perform do |job, block|
    # Timeout jobs after 10 minutes
    Timeout.timeout(job.class.max_runtime, JobTimeoutError) do
      block.call
    end
  end

  def call_operation!(name, ...)
    MeruAPI::Container[name].call(...).value!
  end

  class << self
    def unique_job!(by: :first_arg, total_limit: 1)
      key = unique_job_key_for!(by:)

      good_job_control_concurrency_with(
        key:,
        enqueue_limit: 1,
        enqueue_throttle: [10, 1.minute],
        total_limit:
      )
    end

    # @api private
    # @return [Proc]
    def unique_job_key_for!(by:)
      # :nocov:
      case by
      when :first_arg
        -> { "#{self.class.name}-#{arguments.first}" }
      when :job
        -> { "#{self.class.name}-instance" }
      else
        -> { "#{self.class.name}-#{queue_name}-#{arguments.inspect}" }
      end
    end
  end
end
