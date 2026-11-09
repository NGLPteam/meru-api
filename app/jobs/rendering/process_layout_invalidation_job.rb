# frozen_string_literal: true

module Rendering
  class ProcessLayoutInvalidationJob < ApplicationJob
    queue_as :layouts

    unique_job! by: -> { "#{self.class.name}-#{queue_name}-#{arguments.first.entity_id}" }

    # @param [LayoutInvalidation] layout_invalidation
    # @return [void]
    def perform(layout_invalidation)
      layout_invalidation.process!
    end
  end
end
