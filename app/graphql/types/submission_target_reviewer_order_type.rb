# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsSubmissionTargetReviewer
  class SubmissionTargetReviewerOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `SubmissionTargetReviewer` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort submission target reviewers by their default order."
    end

    value "RECENT" do
      description "Sort submission target reviewers by newest created date."
    end

    value "OLDEST" do
      description "Sort submission target reviewers by oldest created date."
    end
  end
end
