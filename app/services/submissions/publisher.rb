# frozen_string_literal: true

module Submissions
  # @see Submissions::Publish
  # @see Submissions::PublishJob
  class Publisher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Submissions::Types::Submission
    end

    standard_execution!

    # @return [Dry::Monads::Success(Submission)]
    def call
      run_callbacks :execute do
        yield prepare!
      end

      Success submission
    rescue Statesman::TransitionFailedError
      Success submission
    end

    wrapped_hook! def prepare
      super
    end
  end
end
