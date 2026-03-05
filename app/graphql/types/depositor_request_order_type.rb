# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsDepositorRequest
  class DepositorRequestOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `DepositorRequest` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort depositor requests by their default order."
    end

    value "RECENT" do
      description "Sort depositor requests by newest created date."
    end

    value "OLDEST" do
      description "Sort depositor requests by oldest created date."
    end
  end
end
