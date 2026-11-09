# frozen_string_literal: true

module Entities
  # @see Entities::IndexSearchDocuments
  class IndexSearchDocumentsJob < ApplicationJob
    queue_as :indexing

    queue_with_priority 400

    unique_job! by: :queue_first_id

    # @return [void]
    def perform(entity)
      entity.index_search_documents!
    end
  end
end
