# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::FrontendCacheRevalidateEntity
    class FrontendCacheRevalidateEntity
      include MutationOperations::Base
      include Mutations::Shared::RevalidatesFrontendCache

      revalidation_operation "frontend.cache.revalidate_entity"

      authorizes! :entity, with: :revalidate?

      use_contract! :frontend_cache_revalidate_entity

      # @param [Entity] entity
      # @return [void]
      def call(entity:, **)
        revalidate_frontend_cache!(entity)
      end
    end
  end
end
