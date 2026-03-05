# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsSubmissionComment
  class SubmissionCommentOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `SubmissionComment` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort submission comments by their default order."
    end

    value "RECENT" do
      description "Sort submission comments by newest created date."
    end

    value "OLDEST" do
      description "Sort submission comments by oldest created date."
    end
  end
end
