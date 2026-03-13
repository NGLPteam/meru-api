# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionPublish
    class SubmissionPublish
      include MutationOperations::Base

      use_contract! :submission_publish

      authorizes! :submission, with: :publish?

      # @param [Submission] submission
      # @return [void]
      def call(submission:, **)
        with_attached_result! :submission_publication, submission.publish(user: current_user)

        attach! :submission, submission.reload

        attach! :entity, submission.reload_entity
      end
    end
  end
end
