# frozen_string_literal: true

module Resolvers
  module BySchemaKind
    extend ActiveSupport::Concern

    included do
      option :kind, type: ::Types::SchemaKindType, default: "item"
    end

    def apply_kind_with_community(scope)
      scope.by_kind(:community)
    end

    def apply_kind_with_collection(scope)
      scope.by_kind(:collection)
    end

    def apply_kind_with_item(scope)
      scope.by_kind(:item)
    end

    def apply_kind_with_metadata(scope)
      scope.by_kind(:metadata)
    end
  end
end
