# frozen_string_literal: true

module Frontend
  # Prune {FrontendRevalidation} records older than 30 days.
  class PruneRevalidations
    include Dry::Monads[:result]

    # @return [Dry::Monads::Success(Integer)]
    def call
      count = ::FrontendRevalidation.prunable.delete_all

      Success(count)
    end
  end
end
