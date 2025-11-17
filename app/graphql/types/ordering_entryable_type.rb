# frozen_string_literal: true

module Types
  module OrderingEntryableType
    include Types::BaseInterface

    implements GraphQL::Types::Relay::Node

    description <<~TEXT
    An entity or link which can appear in an ordering.
    TEXT
  end
end
