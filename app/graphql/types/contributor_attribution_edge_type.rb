# frozen_string_literal: true

module Types
  class ContributorAttributionEdgeType < Types::BaseEdge
    graphql_name "ContributorAttributionEdge"

    node_type Types::ContributorAttributionType
  end
end
