# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsSubmissionReview
  class SubmissionReviewOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `SubmissionReview` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort submission reviews by their default order."
    end

    value "RECENT" do
      description "Sort submission reviews by newest created date."
    end

    value "OLDEST" do
      description "Sort submission reviews by oldest created date."
    end
  end
end
