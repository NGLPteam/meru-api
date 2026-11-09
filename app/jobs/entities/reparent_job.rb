# frozen_string_literal: true

module Entities
  # @see Entities::Reparent
  class ReparentJob < ApplicationJob
    queue_as :entities

    queue_with_priority 500

    unique_job! by: -> { "#{self.class.name}-#{arguments.second.to_global_id}" }

    # @param [HierarchicalEntity] parent
    # @param [HierarchicalEntity] child
    # @return [void]
    def perform(parent, child)
      call_operation!("entities.reparent", parent, child)
    end
  end
end
