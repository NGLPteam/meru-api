# frozen_string_literal: true

module Types
  # @see Resolvers::OrderedAsPermalink
  class PermalinkOrderType < Types::BaseEnum
    description <<~TEXT
    Sort a collection of `Permalink` records by specific properties and directions.
    TEXT

    value "DEFAULT" do
      description "Sort permalinks by their default order: canonical first, then by uri alphabetically."
    end

    value "RECENT" do
      description "Sort permalinks by newest created date."
    end

    value "OLDEST" do
      description "Sort permalinks by oldest created date."
    end
  end
end
