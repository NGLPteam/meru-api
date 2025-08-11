# frozen_string_literal: true

module Entities
  # @see Entities::Reparent
  class ReparentJob < ApplicationJob
    queue_as :entities

    queue_with_priority 500

    good_job_control_concurrency_with(
      key: -> { "#{self.class.name}-#{arguments.second.to_global_id}" },
      total_limit: 1
    )

    # @param [HierarchicalEntity] parent
    # @param [HierarchicalEntity] child
    # @return [void]
    def perform(parent, child)
      call_operation!("entities.reparent", parent, child)
    end
  end
end
