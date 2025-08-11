# frozen_string_literal: true

module Harvesting
  module Attempts
    module RecordLinks
      # @see Harvesting::Attempts::RecordLinks::Connect
      class Connector < Support::HookBased::Actor
        include MonadicPersistence
        include Dry::Initializer[undefined: false].define -> do
          param :harvest_attempt, Harvesting::Types::Attempt

          param :harvest_record, Harvesting::Types::Record
        end

        UNIQUE_BY = %i[harvest_attempt_id harvest_record_id].freeze

        delegate :id, to: :harvest_attempt, prefix: true
        delegate :id, to: :harvest_record, prefix: true

        standard_execution!

        # @return [HarvestAttemptRecordLink]
        attr_reader :link

        # @return [Hash]
        attr_reader :tuple

        # @return [Dry::Monads::Success(HarvestAttemptRecordLink)]
        def call
          run_callbacks :execute do
            yield prepare!

            yield upsert!
          end

          Success link
        end

        wrapped_hook! def prepare
          @tuple = build_tuple

          @link = nil

          super
        end

        wrapped_hook! def upsert
          @link = yield monadic_upsert(HarvestAttemptRecordLink, tuple, unique_by: UNIQUE_BY)

          super
        end

        private

        def build_tuple
          {
            harvest_attempt_id:,
            harvest_record_id:
          }
        end
      end
    end
  end
end
