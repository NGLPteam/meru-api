# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::FrontendCacheRevalidateInstance
  class FrontendCacheRevalidateInstance < Mutations::BaseMutation
    description <<~TEXT
    Revalidates the frontend cache for the entire instance.
    TEXT

    field :revalidated, Boolean, null: true do
      description <<~TEXT
      Whether the revalidation request was successfully performed.
      TEXT
    end

    performs_operation! "mutations.operations.frontend_cache_revalidate_instance"
  end
end
