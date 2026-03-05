# frozen_string_literal: true

module Resolvers
  class PageResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::PageType.connection_type, null: false

    resolves_model! ::Page, must_have_object: true
  end
end
