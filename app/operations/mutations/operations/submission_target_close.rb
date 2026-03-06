# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionTargetClose
    class SubmissionTargetClose
      include MutationOperations::Base

      use_contract! :submission_target_close

      authorizes! :submission_target, with: :update?

      # @param [SubmissionTarget] submission_target
      # @return [void]
      def call(submission_target:, **)
        submission_target.transition_to! :closed

        attach! :submission_target, submission_target.reload
      end
    end
  end
end
