# frozen_string_literal: true

module SubmissionTargets
  # Fetch or initialize a {SubmissionTarget} for a given {HierarchicalEntity}.
  #
  # @see SubmissionTargets::Fetch
  class Fetcher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, SubmissionTargets::Types::Entity
    end

    standard_execution!

    # @return [SubmissionTarget]
    attr_reader :submission_target

    around_execute :lock_submission_target!

    # @return [Dry::Monads::Success(SubmissionTarget)]
    def call
      run_callbacks :execute do
        yield prepare!
      end

      Success submission_target
    end

    wrapped_hook! def prepare
      @submission_target = entity.submission_target || entity.create_submission_target!

      super
    end

    private

    # @return [void]
    def lock_submission_target!
      entity.with_lock do
        entity.with_advisory_lock("submission_target_fetcher:#{entity.id}", transaction: true, timeout_seconds: 10) do
          yield
        end
      end
    end
  end
end
