# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::SubmissionCreate
    # @see Mutations::Operations::SubmissionCreate
    class SubmissionCreate < MutationOperations::Contract
      json do
        required(:submission_target).value(:submission_target)
        required(:schema_version).value(:schema_version)
        required(:parent_entity).value(:any_entity)
        required(:title).filled(:string)
      end
    end
  end
end
