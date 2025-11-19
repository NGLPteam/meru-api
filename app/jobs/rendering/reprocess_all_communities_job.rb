# frozen_string_literal: true

module Rendering
  # Enqueues reprocessing jobs for all {Community} entities.
  class ReprocessAllCommunitiesJob < AbstractReprocessEntitiesJob
    entity_klass Community

    queue_with_priority 300
  end
end
