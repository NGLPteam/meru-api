# frozen_string_literal: true

module Support
  # A concern that assists in lazy evaluation of values, for instance
  # models and other application-specific code that needs to be referenced in VOG.
  module Realizable
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :realize, :realization
    end

    # @return [Boolean]
    attr_reader :realized

    alias realized? realized

    def initialize(...)
      super

      @realized = false
    end

    # @api private
    # @param [Boolean] reset whether to allow re-realization of an already-realized wrapper
    # @return [void]
    def realize!(reset: false)
      # :nocov:
      raise AlreadyRealized, "Already realized" if realized? && !reset
      # :nocov:

      run_callbacks :realize do
        realization!

        @realized = true
      end
    end

    # @abstract
    # @return [void]
    def realization
      # :nocov:
      raise NotImplementedError, "Must implement #realization in including class"
      # :nocov:
    end

    # @api private
    # @return [void]
    def realization!
      run_callbacks :realization do
        realization
      end
    end

    # A hook to check for realization.
    # @api private
    # @raise [Support::Realizable::Unrealized] if the wrapper has not been realized
    # @return [void]
    def realized!
      raise Unrealized, "Must be realized" unless realized?
    end

    # @abstract Generic realization errors.
    class Error < StandardError; end

    # An error raised when attempting to realize something that has already been realized.
    class AlreadyRealized < Error; end

    # An error raised when attempting to access a value before it is ready.
    class Unrealized < Error; end
  end
end
