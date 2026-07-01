# frozen_string_literal: true

module Types
  class AnyContributorAttributionType < Types::BaseUnion
    possible_types Types::ContributorCollectionAttributionType, Types::ContributorItemAttributionType

    class << self
      def resolve_type(object, context)
        # simplecov:disable
        raise TypeError, "not a contributor: #{object.inspect}" unless object.kind_of?(ContributorAttribution)

        object.graphql_node_type
        # simplecov:enable
      end
    end
  end
end
