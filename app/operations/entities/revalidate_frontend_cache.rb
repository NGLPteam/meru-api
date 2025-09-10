# frozen_string_literal: true

module Entities
  # An operation that revalidates the frontend cache for a certain entity.
  #
  # It will quietly swallow any errors, since revalidation is not critical.
  # @see Frontend::Cache::RevalidateEntity
  # @see Frontend::Cache::EntityRevalidator
  class RevalidateFrontendCache
    include Dry::Monads[:result]

    include MeruAPI::Deps[
      revalidate: "frontend.cache.revalidate_entity",
    ]

    # @param [HierarchicalEntity] entity
    # @return [Dry::Monads::Success(void)]
    def call(entity)
      revalidate.(entity).or do
        Success()
      end
    end
  end
end
