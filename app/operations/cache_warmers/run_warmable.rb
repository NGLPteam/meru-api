# frozen_string_literal: true

module CacheWarmers
  # An operation to run the {CacheWarmer} for a given {CacheWarmable} record.
  #
  # @see CacheWarmable
  # @see CacheWarmer
  # @see CacheWarmers::Run
  # @see CacheWarmers::Runner
  class RunWarmable
    include Dry::Monads[:result]

    # @param [CacheWarmable] warmable
    # @return [Dry::Monads::Success(Integer)]
    def call(warmable)
      cache_warmer = warmable.cache_warmer

      return Success(0) unless cache_warmer.present?

      cache_warmer.run
    end
  end
end
