# frozen_string_literal: true

module Entities
  class ReprocessLayoutsJob < ApplicationJob
    queue_as :layouts

    queue_with_priority do
      case arguments.first
      when ::Item then 500
      when ::Collection then 600
      when ::Community then 700
      else
        # :nocov:
        999
        # :nocov:
      end
    end

    # @param [HierarchicalEntity] entity
    # @return [void]
    def perform(entity)
      call_operation!("entities.reprocess_layouts", entity)
    end
  end
end
