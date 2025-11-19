# frozen_string_literal: true

module Rendering
  # Enqueues reprocessing jobs for all {Item} entities.
  class ReprocessAllItemsJob < AbstractReprocessEntitiesJob
    entity_klass Item

    queue_with_priority 100
  end
end
