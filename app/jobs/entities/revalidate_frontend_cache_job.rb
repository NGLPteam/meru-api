# frozen_string_literal: true

module Entities
  # @see Entities::RevalidateFrontendCache
  class RevalidateFrontendCacheJob < ApplicationJob
    queue_as :default

    queue_with_priority 400

    good_job_control_concurrency_with(
      total_limit: 3,
      # simplecov:disable
      key: -> { "#{self.class.name}-#{arguments.first.id}" }
      # simplecov:enable
    )

    # @param [HierarchicalEntity] entity
    # @return [void]
    def perform(entity)
      entity.revalidate_frontend_cache!
    end
  end
end
