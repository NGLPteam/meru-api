# frozen_string_literal: true

module Types
  class PermalinkableKindType < Types::BaseEnum
    description <<~TEXT
    An enum that helps describe the different kinds of records
    that can be permalinked.
    TEXT

    value "COMMUNITY", value: "community" do
      description <<~TEXT
      This permalink points to a community.
      TEXT
    end

    value "COLLECTION", value: "collection" do
      description <<~TEXT
      This permalink points to a collection.
      TEXT
    end

    value "ITEM", value: "item" do
      description <<~TEXT
      This permalink points to an item.
      TEXT
    end
  end
end
