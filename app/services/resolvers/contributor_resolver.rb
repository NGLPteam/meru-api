# frozen_string_literal: true

module Resolvers
  class ContributorResolver < AbstractResolver
    include Resolvers::OrderedAsContributor
    include Resolvers::Enhancements::PageBasedPagination

    applies_policy_scope!

    type ::Types::AnyContributorType.connection_type, null: false

    max_page_size 1000

    resolves_model! ::Contributor

    filters_with! Filtering::Scopes::Contributors

    option :kind, type: ::Types::ContributorFilterKindType, default: "ALL"

    PREFIX_DESC = <<~TEXT
    Search for contributors with names that start with the provided text.

    **Deprecated**: Use the `nameSearch` filter instead.
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
