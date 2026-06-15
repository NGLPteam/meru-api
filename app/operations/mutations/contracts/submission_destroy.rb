# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionDestroy
    # @see Mutations::Operations::SubmissionDestroy
    class SubmissionDestroy < MutationOperations::Contract
      json do
        required(:submission).value(:submission)
      end

      rule(:submission) do
        base.failure(:only_draft_submissions_destructible) unless value.draft?
      end
    end
  end
end
