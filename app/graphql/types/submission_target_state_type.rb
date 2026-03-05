# frozen_string_literal: true

module Types
  # @see SubmissionTargets::StateMachine
  class SubmissionTargetStateType < Types::BaseEnum
    description <<~TEXT
    The state of a submission target, describing whether it is accepting submissions or not.
    TEXT

    value "CLOSED", value: "closed" do
      description <<~TEXT
      The submission target is not accepting submissions.
      TEXT
    end

    value "OPEN", value: "open" do
      description <<~TEXT
      The submission target is accepting submissions.
      TEXT
    end
  end
end
