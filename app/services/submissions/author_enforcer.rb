# frozen_string_literal: true

module Submissions
  # @see Submissions::EnforceAuthor
  class AuthorEnforcer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Submissions::Types::Submission
    end

    standard_execution!

    # @return [Role]
    attr_reader :author_role

    # @return [Dry::Monads::Success(void)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield grant_role!
      end

      Success()
    end

    wrapped_hook! def prepare
      @author_role = Role.fetch(:author)

      super
    end

    wrapped_hook! def grant_role
      yield MeruAPI::Container["access.grant"].(author_role, on: submission.entity, to: submission.user)

      super
    end
  end
end
