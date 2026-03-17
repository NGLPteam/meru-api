# frozen_string_literal: true

module Entities
  # A manually-invoked job to reindex all search properties.
  #
  # @see Schemas::Instances::ExtractSearchablePropertiesJob
  # @see Schemas::Instances::Reindex
  # @see Schemas::Instances::ReindexJob
  class ReindexSearchJob < ApplicationJob
    include JobIteration::Iteration

    queue_as :maintenance

    unique_job! by: :job

    # @return [void]
    def build_enumerator(cursor:)
      enumerator_builder.active_record_on_records(
        ::Entity.real.preload(:hierarchical),
        cursor:,
      )
    end

    # @param [Entity] entity
    # @return [void]
    def each_iteration(entity)
      Schemas::Instances::ReindexJob.perform_later entity.hierarchical
    end
  end
end
