# frozen_string_literal: true

module Schemas
  module Static
    module TracksLayoutDefinitions
      extend ActiveSupport::Concern

      included do
        include Dry::Effects::Handler.Reader(:skip_layout_invalidation)
        include Dry::Effects::Handler.State(:layout_definitions)
      end

      # @return [void]
      def capture_layout_definitions_to_invalidate!
        layout_definitions, result = with_layout_definitions([]) do
          with_skip_layout_invalidation(true) do
            yield
          end
        end

        # :nocov:
        if LayoutsConfig.invalidate_on_deploy?
          # Not an operation that should/can fail.
          MeruAPI::Container["layouts.invalidate_batch"].(layout_definitions).value!
        end
        # :nocov:

        return result
      end
    end
  end
end
