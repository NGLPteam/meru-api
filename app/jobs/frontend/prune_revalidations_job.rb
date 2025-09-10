# frozen_string_literal: true

module Frontend
  class PruneRevalidationsJob < ApplicationJob
    queue_as :maintenance

    # @return [void]
    def perform
      call_operation!("frontend.prune_revalidations")
    end
  end
end
