# frozen_string_literal: true

# @see ScopesForEntityComposedText
class EntityComposedText < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :entity, polymorphic: true, inverse_of: :entity_composed_text

  class << self
    # @param [String] query
    # @param [String] dictionary
    # @param [Boolean] allow_no_matched_join
    # @return [ActiveRecord::Relation<EntityComposedText>]
    def websearch(query, dictionary: "english", allow_no_matched_join: false)
      tsquery = arel_named_fn("websearch_to_tsquery", dictionary, query)

      expr = arel_infix("@@", arel_table[:document], tsquery)

      expr = allow_no_matched_join ? expr.or(arel_table[:document].eq(nil)) : arel_table[:document].not_eq(nil).and(expr)

      where(expr)
    end
  end
end
