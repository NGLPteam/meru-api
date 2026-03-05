# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsSubmissionTarget
  class SubmissionTargetOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `SubmissionTarget` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort submission targets by their default order."
    end

    value "RECENT" do
      description "Sort submission targets by newest created date."
    end

    value "OLDEST" do
      description "Sort submission targets by oldest created date."
    end
  end
end
