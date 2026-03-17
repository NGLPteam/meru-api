# frozen_string_literal: true

module Mutations
  # @see ModelMutationSupport
  class Current < ActiveSupport::CurrentAttributes
    attribute :active, default: proc { false }

    resets do
      self.active = false
    end

    class << self
      # Set the current mutation as active for the duration of a block using
      # `ActiveSupport::CurrentAttributes`.
      #
      # @yield a block where the current mutation will be active
      # @return [void]
      def with_active!(active: false, &)
        set(active:, &)
      end
    end
  end
end
