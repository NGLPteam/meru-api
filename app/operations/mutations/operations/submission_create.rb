# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::SubmissionCreate
    class SubmissionCreate
      include MutationOperations::Base

      use_contract! :submission_create

      authorizes! :submission_target, with: :deposit?

      authorizes! :submission, with: :create?

      # @param [Submission] submission
      # @param [Hash] attrs
      # @return [void]
      def call(submission:, **attrs)
        assign_attributes!(submission, **attrs)

        persist_model! submission, attach_to: :submission
      end

      before_prepare def initialize_submission!
        args => { submission_target:, schema_version:, parent_entity: }

        attrs = { submission_target:, schema_version:, parent_entity:, user: current_user.authenticated }

        args[:submission] = Submission.new(**attrs)
      end
    end
  end
end
