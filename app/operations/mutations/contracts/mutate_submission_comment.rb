# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::MutateSubmissionComment
    class MutateSubmissionComment < MutationOperations::Contract
      json do
        required(:content).filled(:string)
      end
    end
  end
end
