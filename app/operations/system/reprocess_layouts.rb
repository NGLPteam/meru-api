# frozen_string_literal: true

module System
  # @api private
  class ReprocessLayouts
    include Dry::Monads[:result]

    def call
      Community.find_each(&:reprocess_layouts!)

      Collection.roots.find_each(&:reprocess_layouts!)

      Collection.filtered_by_schema_version("nglp:journal_volume").find_each(&:reprocess_layouts!)

      Collection.filtered_by_schema_version("nglp:journal_issue").find_each(&:reprocess_layouts!)

      Rendering::ReprocessAllEntitiesJob.perform_later

      Success()
    end
  end
end
