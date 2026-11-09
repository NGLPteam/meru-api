# frozen_string_literal: true

# @abstract
class ApplicationJob < ActiveJob::Base
  extend Dry::Core::ClassAttributes

  # The extension must be included before other extensions
  include GoodJob::ActiveJobExtensions::InterruptErrors

  include GoodJob::ActiveJobExtensions::Concurrency

  UNIQUE_LABELS = {
    args: -> { "#{self.class.name}-#{queue_name}-#{arguments.inspect}" },
    first_arg: -> { "#{self.class.name}-#{arguments.first}" },
    job: -> { "#{self.class.name}-instance" },
    queue: -> { "#{self.class.name}-#{queue_name}" },
    queue_first_id: -> { "#{self.class.name}-#{queue_name}-#{arguments.first.id}" }
  }.tap do |h|
    h.default = h[:args]
  end.freeze

  retry_on ActiveRecord::QueryCanceled, wait: :polynomially_longer, attempts: 10

  retry_on ActiveRecord::StatementInvalid, wait: :polynomially_longer, attempts: 10

  retry_on GoodJob::InterruptError, wait: :polynomially_longer, attempts: Float::INFINITY

  retry_on GoodJob::ActiveJobExtensions::Concurrency::ThrottleExceededError, wait: :polynomially_longer, attempts: 10

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # This error is unlikely to resolve itself on subsequent executions.
  # simplecov:disable
  discard_on NameError unless Rails.env.test?
  # simplecov:enable

  def call_operation!(name, ...)
    MeruAPI::Container[name].call(...).value!
  end

  class << self
    # @param [Symbol, Proc] by
    # @param [Integer] total_limit
    # @return [void]
    def unique_job!(by: :first_arg, total_limit: 1)
      label = unique_job_key_for!(by:)

      self.good_job_labels = [label]

      good_job_concurrency_rule(
        label:,
        enqueue_limit: 1,
        enqueue_throttle: [10, 1.minute],
        total_limit:
      )
    end

    # @api private
    # @param [Symbol, Proc] by
    # @return [Proc]
    def unique_job_key_for!(by:)
      case by
      when Proc
        by
      when Symbol
        UNIQUE_LABELS[by]
      else
        # simplecov:disable
        raise ArgumentError, "Invalid unique job key: #{by.inspect}"
        # simplecov:enable
      end
    end
  end
end
