# frozen_string_literal: true

module Harvesting
  module Attempts
    module EntityLinks
      # A concern for laoding {HarvestAttemptEntityLink} records within services.
      #
      # It depends on the service implementing {#harvest_attempt} and {#harvest_entity}.
      module Loading
        extend ActiveSupport::Concern

        # @return [HarvestAttemptEntityLink, nil]
        def load_harvest_attempt_entity_link
          # simplecov:disable
          return unless harvest_attempt.present?
          # simplecov:enable

          harvest_attempt.connect_entity!(harvest_entity)
        end
      end
    end
  end
end
