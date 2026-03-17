# frozen_string_literal: true

module Schemas
  module Orderings
    # @see Schemas::Orderings
    # @see Schemas::Orderings::RefreshStatus
    class Current < ActiveSupport::CurrentAttributes
      attribute :refresh_status, default: proc { Schemas::Orderings::RefreshStatus.new }

      delegate :async?, :disabled?, :mode, :sync?, to: :refresh_status

      resets do
        self.refresh_status = Schemas::Orderings::RefreshStatus.new
      end

      class << self
        # Set the current {Ordering} refresh mode for the duration of a block
        # using `ActiveSupport::CurrentAttributes`.
        #
        # @param ["async", "disabled", "sync"] mode
        # @yield a block where the provided refresh mode will be in effect
        # @return [void]
        def refresh_with!(mode:, &)
          refresh_status = Schemas::Orderings::RefreshStatus.new(mode:)

          set(refresh_status:, &)
        end
      end
    end
  end
end
