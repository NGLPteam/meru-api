# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::DepositorRequestCreate
  class DepositorRequestCreate < Mutations::BaseMutation
    description <<~TEXT
    Create a single `DepositorRequest` record.
    TEXT

    field :depositor_request, Types::DepositorRequestType, null: true do
      description <<~TEXT
      The newly-modified depositor request, if successful.
      TEXT
    end

    argument :submission_target_id, ID, required: true, loads: Types::SubmissionTargetType do
      description <<~TEXT
      The ID of the submission target for which to create the depositor request.
      TEXT
    end

    argument :message, String, required: false do
      description <<~TEXT
      An optional message to include with the depositor request.
      TEXT
    end

    performs_operation! "mutations.operations.depositor_request_create"
  end
end
