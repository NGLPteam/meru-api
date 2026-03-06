# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionTargetOpen
    class SubmissionTargetOpen
      include MutationOperations::Base

      use_contract! :submission_target_open

      authorizes! :submission_target, with: :update?

      # @param [SubmissionTarget] submission_target
      # @return [void]
      def call(submission_target:, **)
        submission_target.transition_to! :open

        attach! :submission_target, submission_target.reload
      end
    end
  end
end
