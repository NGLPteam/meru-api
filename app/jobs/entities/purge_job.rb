# frozen_string_literal: true

module Entities
  # @see Entities::Purge
  # @see Entities::Purger
  class PurgeJob < ApplicationJob
    queue_as :purging

    unique_job! by: :queue_first_id

    # @param [HierarchicalEntity] entity
    # @return [void]
    def perform(entity)
      call_operation!("entities.purge", entity)
    end
  end
end
