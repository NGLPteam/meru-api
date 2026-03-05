# frozen_string_literal: true

module Types
  # @see SubmissionTargets::Description
  # @see Types::SubmissionTargetDescriptionInputType
  class SubmissionTargetDescriptionType < Types::BaseObject
    description <<~TEXT
    An object representing the description of a submission target.
    TEXT

    field :internal, String, null: false do
      description <<~TEXT
      The internal description of the action.
      This is a detailed description that may include technical information and is intended for internal use only. It should not be displayed to end users.
      TEXT
    end

    field :instructions, String, null: false do
      description <<~TEXT
      This is a preface to the sections that provides a high-level overview of the action and is intended to be displayed to end users.
      TEXT
    end

    field :sections, [Types::SubmissionTargetSectionType, { null: false }], null: false do
      description <<~TEXT
      The ordered sections of the action's description.
      TEXT
    end
  end
end
