# frozen_string_literal: true

module Entities
  # @see Entities::RevalidateFrontendCache
  class RevalidateFrontendCacheJob < ApplicationJob
    queue_as :default

    queue_with_priority 400

    unique_job! by: :queue_first_id, total_limit: 3

    # @param [HierarchicalEntity] entity
    # @return [void]
    def perform(entity)
      entity.revalidate_frontend_cache!
    end
  end
end
