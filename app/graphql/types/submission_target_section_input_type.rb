# frozen_string_literal: true

module Types
  # @see SubmissionTargets::Section
  # @see Types::SubmissionTargetSectionType
  class SubmissionTargetSectionInputType < Types::HashInputObject
    description <<~TEXT
    An input object representing a section of a submission target's description.
    TEXT

    argument :name, String, required: true do
      description <<~TEXT
      The name of the section. This is used to identify the section and should be unique within a submission target.
      TEXT
    end

    argument :content, String, required: true do
      description <<~TEXT
      The content of the section. This is the actual text that will be displayed for this section of the submission target's description.
      TEXT
    end
  end
end
