# frozen_string_literal: true

module Rendering
  # Enqueues reprocessing jobs for all {Collection} entities.
  class ReprocessAllCollectionsJob < AbstractReprocessEntitiesJob
    entity_klass Collection

    queue_with_priority 200
  end
end
