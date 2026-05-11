# frozen_string_literal: true

module Contributors
  # An inline merge that will execute {Contributors::MergeJob} in the same process.
  # This is intended for manual one-offs and scripts.
  #
  # @see Contributors::Merge
  class Merger < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :source, Types::Contributor

      param :target, Types::Contributor
    end

    standard_execution!

    # @return [Dry::Monads::Success(Contributor)]
    def call
      run_callbacks :execute do
        yield verify_merge_lock!

        yield perform_merge!
      end

      Success target.reload
    end

    wrapped_hook! def verify_merge_lock
      yield source.merge_to(target)

      super
    end

    wrapped_hook! def perform_merge
      Contributors::MergeJob.perform_now(source, target)
    rescue Contributors::MergeFailed => e
      Failure[:merge_failed, "Merge failed for #{source.id} -> #{target.id}: #{e.message}"]
    else
      super
    end
  end
end
