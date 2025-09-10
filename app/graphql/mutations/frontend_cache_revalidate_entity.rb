# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::FrontendCacheRevalidateEntity
  class FrontendCacheRevalidateEntity < Mutations::BaseMutation
    description <<~TEXT
    Revalidates the frontend cache for a given entity.
    TEXT

    field :revalidated, Boolean, null: true do
      description <<~TEXT
      Whether the revalidation request was successfully performed.
      TEXT
    end

    argument :entity_id, ID, loads: Types::EntityType, required: true do
      description <<~TEXT
      The entity to update.
      TEXT
    end

    performs_operation! "mutations.operations.frontend_cache_revalidate_entity"
  end
end
