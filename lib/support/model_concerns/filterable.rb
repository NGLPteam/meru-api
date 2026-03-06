# frozen_string_literal: true

# An ActiveRecord model concern providing filtering capabilities.
module Filterable
  extend ActiveSupport::Concern

  # Class methods for the {Filterable} concern.
  module ClassMethods
    # @param [Symbol] association
    # @param [Filtering::FilterScope] filters
    # @return [ActiveRecord::Relation]
    def filter_by_nested(association, filters)
      return all if filters.nil?

      inner_scope = unscoped.joins(association)
        .merge(filters.call)
        .reselect(:id).reorder(nil)

      where(id: inner_scope)
    end

    # @note This is for compatibility with search scoping, since we might be delegating a typeahead search.
    # @return [ActiveRecord::Relation]
    def with_pg_search_rank
      all
    end
  end
end
