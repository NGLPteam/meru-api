# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionChangeState
    class SubmissionChangeState
      include MutationOperations::Base

      use_contract! :submission_change_state

      authorizes! :submission_status, with: :transition?

      # @param [Submission] submission
      # @param [String] to_state
      # @return [void]
      def call(submission:, to_state:, **)
        submission.transition_to! to_state

        attach! :submission, submission.reload
      end

      before_prepare def build_status!
        args => { submission:, to_state: }

        args[:submission_status] = Submissions::Status.new(submission, to_state:)
      end
    end
  end
end
