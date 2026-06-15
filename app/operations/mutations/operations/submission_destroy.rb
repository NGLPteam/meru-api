# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionDestroy
    class SubmissionDestroy
      include MutationOperations::Base

      use_contract! :submission_destroy

      authorizes! :submission, with: :destroy?

      # @param [Submission] submission
      # @return [void]
      def call(submission:)
        destroy_model! submission, auth: true
      end
    end
  end
end
