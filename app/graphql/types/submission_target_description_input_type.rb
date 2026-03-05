# frozen_string_literal: true

module Types
  # @see SubmissionTargets::Description
  # @see Types::SubmissionTargetDescriptionType
  class SubmissionTargetDescriptionInputType < Types::HashInputObject
    description <<~TEXT
    An input object representing the description of a submission target.
    TEXT

    argument :internal, String, required: false, default_value: "", replace_null_with_default: true do
      description <<~TEXT
      The internal description of the action.
      This is a detailed description that may include technical information and is intended for internal use only. It should not be displayed to end users.
      TEXT
    end

    argument :instructions, String, required: false, default_value: "", replace_null_with_default: true do
      description <<~TEXT
      This is a preface to the sections that provides a high-level overview of the action and is intended to be displayed to end users.
      TEXT
    end

    argument :sections, [Types::SubmissionTargetSectionInputType], required: true do
      description <<~TEXT
      The ordered sections of the action's description.

      The order provided here will be used as the order of the sections in the action's description.
      TEXT
    end
  end
end
