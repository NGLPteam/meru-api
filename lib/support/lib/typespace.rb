# frozen_string_literal: true

module Support
  # A module for building namespaced types.
  module Typespace
    # @return [Module] A cached reference to a `Dry.Types` module.
    DRY_TYPES = Dry.Types

    class << self
      # @param [Module] mod
      # @return [void]
      def extended(mod)
        super

        mod.include DRY_TYPES

        mod.extend Support::EnhancedTypes
      end
    end
  end
end
