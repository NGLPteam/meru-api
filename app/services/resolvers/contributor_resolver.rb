# frozen_string_literal: true

module Resolvers
  class ContributorResolver < GraphQL::Schema::Resolver
    include SearchObject.module(:graphql)

    include Resolvers::AppliesPolicyScope
    include Resolvers::OrderedAsContributor
    include Resolvers::PageBasedPagination

    type Types::AnyContributorType.connection_type, null: false

    max_page_size 1000

    scope { object.present? ? object.contributors : Contributor.all }

    option :kind, type: Types::ContributorFilterKindType, default: "ALL"

    PREFIX_DESC = <<~TEXT
    Search for contributors with names that start with the provided text.
    TEXT

    option :prefix, type: String, description: PREFIX_DESC do |scope, value|
      scope.apply_prefix value
    end

    def apply_kind_with_all(scope)
      scope.all
    end

    def apply_kind_with_organization(scope)
      scope.organization
    end

    def apply_kind_with_person(scope)
      scope.person
    end
  end
end
