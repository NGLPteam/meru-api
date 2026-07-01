# frozen_string_literal: true

module Submissions
  # @see Submission#clean_up
  # @see Submissions::CleanUp
  class Cleaner < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Types::Submission
    end

    standard_execution!

    # @return [Dry::Monads::Success(Submission)]
    def call
      run_callbacks :execute do
        yield purge_entity!
      end

      submission.reload
      submission.reload_entity

      Success submission
    end

    wrapped_hook! def purge_entity
      # simplecov:disable
      return Success() unless submission.entity
      # simplecov:enable

      yield submission.entity.purge

      Success()
    end
  end
end
