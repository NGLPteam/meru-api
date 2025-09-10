# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::FrontendCacheRevalidateInstance
    class FrontendCacheRevalidateInstance
      include MutationOperations::Base
      include Mutations::Shared::RevalidatesFrontendCache

      revalidation_operation "frontend.cache.revalidate_instance"

      authorizes! :current_user, with: :revalidate_instance?

      # @param [Entity] entity
      # @param [{ Symbol => Object }] attrs
      # @return [void]
      def call(**)
        revalidate_frontend_cache!
      end
    end
  end
end
