# frozen_string_literal: true

module Contributors
  class RefreshAttributionsJob < ApplicationJob
    queue_as :default

    unique_job! by: :job

    # @return [void]
    def perform
      ContributorAttribution.refresh!
    end
  end
end
