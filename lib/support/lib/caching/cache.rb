# frozen_string_literal: true

module Support
  module Caching
    # A caching mechanism for GraphQL requests that is safe to use
    # within the context of a request, whether it dips into threads or fibers.
    #
    # This marries cache with the Reader effect to specify whether or not the cache
    # is active or not. It allows for safe evaluation of anything with the ability
    # to cache it in certain contexts.
    #
    # @api private
    class Cache
      def vog_cache(...)
        if vog_safe_cache_active?
          cache(...)
        else
          yield
        end
      end

      # Activates the VOG cache for the duration of the block
      # within a Thread.current variable.
      # @return [void]
      def with_vog_cache
        # :nocov:
        return yield if vog_safe_cache_active?
        # :nocov:

        with_vog_safe_cache_active! do
          with_cache! do
            yield
          end
        end
      end

      # @!attribute [r] vog_safe_cache_active
      # @return [Boolean]
      def vog_safe_cache_active
        Thread.current.thread_variable_get(:vog_safe_cache_active) || false
      end

      alias vog_safe_cache_active? vog_safe_cache_active

      alias vog_cache_active? vog_safe_cache_active

      # @!attribute [r] vog_safe_cache
      # @return [Concurrent::Map, nil]
      def vog_safe_cache
        Thread.current.thread_variable_get(:vog_safe_cache)
      end

      # @api private
      # @param [Array<Object>] args the args to key by
      # @return [Object]
      def cache(*args, &)
        vog_safe_cache.then do |c|
          # :nocov:
          return yield if c.nil?
          # :nocov:

          c.compute_if_absent(args, &)
        end
      end

      # @return [void]
      def with_cache!
        original = vog_safe_cache

        Thread.current.thread_variable_set(:vog_safe_cache, Concurrent::Map.new)

        yield
      ensure
        Thread.current.thread_variable_set(:vog_safe_cache, original)
      end

      # @return [void]
      def with_vog_safe_cache_active!
        original = vog_safe_cache_active

        Thread.current.thread_variable_set(:vog_safe_cache_active, true)

        yield
      ensure
        Thread.current.thread_variable_set(:vog_safe_cache_active, original)
      end

      class << self
        # @return [Support::Caching::Cache]
        def instance
          @instance ||= new
        end

        delegate :vog_cache_active?, :vog_cache, :with_vog_cache, to: :instance
      end
    end
  end
end
