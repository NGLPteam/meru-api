# frozen_string_literal: true

module Rendering
  # Enqueues reprocessing jobs for all entities.
  class ReprocessAllEntitiesJob < ApplicationJob
    queue_as :default

    # @return [void]
    def perform
      Rendering::ReprocessAllItemsJob.perform_later
      Rendering::ReprocessAllCollectionsJob.perform_later
      Rendering::ReprocessAllCommunitiesJob.perform_later
    end
  end
end
