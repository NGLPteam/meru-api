# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsSubmission
  class SubmissionOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `Submission` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort submissions by their default order."
    end

    value "RECENT" do
      description "Sort submissions by newest created date."
    end

    value "OLDEST" do
      description "Sort submissions by oldest created date."
    end
  end
end
