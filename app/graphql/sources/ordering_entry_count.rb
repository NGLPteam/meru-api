# frozen_string_literal: true

module Sources
  class OrderingEntryCount < GraphQL::Dataloader::Source
    # @param [<Ordering>] orderings
    def fetch(orderings)
      counts = OrderingEntry.visible_count_for orderings

      orderings.map { |ordering| counts[ordering.id] || 0 }
    end
  end
end
