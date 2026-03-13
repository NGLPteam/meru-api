# frozen_string_literal: true

module SubmissionPublications
  # This serves as a wrapper around {Submissions::Publisher}.
  #
  # @see SubmissionPublications::Publish
  class Publisher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission_publication, Types::SubmissionPublication

      option :submission, Types::Submission, default: -> { submission_publication.submission }

      option :user, Types::User, default: -> { submission_publication.user }
    end

    standard_execution!

    # @return [User, AnonymousUser]
    attr_reader :current_user

    # @return [Dry::Monads::Success(SubmissionPublication)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield publish!
      end

      Success submission_publication.reload
    end

    wrapped_hook! def prepare
      @current_user = user || AnonymousUser.new

      super
    end

    wrapped_hook! def publish
      yield submission.publish(submission_publication:, user:)

      super
    end

    around_publish :set_current_user!

    private

    # @return [void]
    def set_current_user!
      ::Support::Requests::Current.set(current_user:) do
        yield
      end
    end
  end
end
