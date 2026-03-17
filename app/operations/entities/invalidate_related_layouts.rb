# frozen_string_literal: true

module Entities
  # Mark a given entity's ancestors and descendants as stale.
  #
  # @see Entities::InvalidateAncestorLayoutsJob
  # @see Entities::InvalidateDescendantLayoutsJob
  class InvalidateRelatedLayouts
    include Dry::Monads[:result]

    # @param [HierarchicalEntity] entity
    # @return [Dry::Monads::Success(void)]
    def call(entity)
      Entities::InvalidateAncestorLayoutsJob.perform_later entity

      Entities::InvalidateDescendantLayoutsJob.perform_later entity

      Success()
    end
  end
end
