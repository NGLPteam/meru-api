# frozen_string_literal: true

module Resolvers
  class LinkTargetCandidateResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::LinkTargetCandidateType.connection_type, null: false

    resolves_model! ::LinkTargetCandidate, must_have_object: true

    option :kind, type: ::Types::LinkTargetCandidateFilterType, default: "ALL"

    option :title, type: String, default: "" do |scope, value|
      scope.matching_title(value)
    end

    def apply_kind_with_all(scope)
      scope.all
    end

    def apply_kind_with_collection(scope)
      scope.collections
    end

    def apply_kind_with_item(scope)
      scope.items
    end

    def resolve_default_scope
      super.preload(:target).order(title: :asc)
    end
  end
end
