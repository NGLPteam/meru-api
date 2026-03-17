# frozen_string_literal: true

module Schemas
  module Instances
    # @see Schemas::Instances::ExtractComposedTextsJob
    # @see Schemas::Instances::ExtractSearchablePropertiesJob
    class ReindexJob < ApplicationJob
      queue_as :maintenance

      # @param [HierarchicalEntity] entity
      # @return [void]
      def perform(entity)
        call_operation! "schemas.instances.reindex", entity
      end
    end
  end
end
