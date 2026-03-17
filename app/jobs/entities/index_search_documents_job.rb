# frozen_string_literal: true

module Entities
  # @see Entities::IndexSearchDocuments
  class IndexSearchDocumentsJob < ApplicationJob
    queue_as :indexing

    queue_with_priority 400

    good_job_control_concurrency_with(
      total_limit: 1,
      key: -> { "#{self.class.name}-#{queue_name}-#{arguments.first.id}" }
    )

    # @return [void]
    def perform(entity)
      entity.index_search_documents!
    end
  end
end
