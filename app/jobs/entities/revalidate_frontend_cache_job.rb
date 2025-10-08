# frozen_string_literal: true

module Entities
  # @see Entities::RevalidateFrontendCache
  class RevalidateFrontendCacheJob < ApplicationJob
    queue_as :revalidations

    good_job_control_concurrency_with(
      total_limit: 1,
      # :nocov:
      key: -> { "#{self.class.name}-#{arguments.first.id}" }
      # :nocov:
    )

    # @param [HierarchicalEntity] entity
    # @return [void]
    def perform(entity)
      entity.revalidate_frontend_cache!
    end
  end
end
