# frozen_string_literal: true

module Harvesting
  module Configurations
    # @api private
    class Progress
      include Redis::Objects
      include Dry::Core::Equalizer.new(:configuration_id)
      include Dry::Initializer[undefined: false].define -> do
        param :configuration, Harvesting::Types::Configuration
      end

      self.redis_prefix = "harvesting__configurations__progress"

      delegate :max_record_count, to: :configuration

      delegate :id, to: :configuration, prefix: true

      EXPIRATION = -> { 24.hours.from_now }

      redis_id_field :configuration_id

      counter :batches, expireat: EXPIRATION
      counter :processed, expireat: EXPIRATION
      counter :records, expireat: EXPIRATION

      def done?
        processed.value >= configuration.record_count
      end

      def exceeded_max_records?
        processed.value >= max_record_count
      end

      # @return [void]
      def reset!
        counters.each(&:reset)
      end

      def batches!
        batches.increment
      end

      def records!(count = 0)
        records.incrby count
      end

      # @return [Boolean]
      def processed!(count = 0)
        processed.incrby count
      end

      def should_stop?
        exceeded_max_records?
      end

      private

      def counters
        [batches, processed, records]
      end
    end
  end
end
