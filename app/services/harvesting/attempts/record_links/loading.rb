# frozen_string_literal: true

module Harvesting
  module Attempts
    module RecordLinks
      # A concern for laoding {HarvestAttemptRecordLink} records within services.
      #
      # It depends on the service implementing {#harvest_attempt} and {#harvest_record}.
      module Loading
        extend ActiveSupport::Concern

        # @return [HarvestAttemptRecordLink, nil]
        def load_harvest_attempt_record_link
          # simplecov:disable
          return unless harvest_attempt.present?
          # simplecov:enable

          harvest_attempt.connect_record!(harvest_record)
        end
      end
    end
  end
end
