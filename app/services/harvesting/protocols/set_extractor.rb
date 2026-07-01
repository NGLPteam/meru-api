# frozen_string_literal: true

module Harvesting
  module Protocols
    # An abstract service used to extract {HarvestSet}s from a {HarvestSource},
    # based on its {HarvestProtocol}, (if available).
    #
    # @abstract
    class SetExtractor
      include Harvesting::Protocols::CursorBasedBatchEnumerator
      include Dry::Effects::Handler.Interrupt(:halt_enumeration, as: :catch_halt_enumeration)
      include Dry::Effects.Interrupt(:halt_enumeration)

      param :harvest_source, ::Harvesting::Types::Source

      delegate :id, to: :harvest_source, prefix: true

      # @return [Harvesting::Protocols::Context]
      attr_reader :protocol

      before_enumeration :mark_sets_refreshed_at!
      around_enumeration :provide_harvest_source!

      def initialize(...)
        super

        @protocol = harvest_source.build_protocol_context
      end

      def call
        each do |harvest_set, _|
          # Intentionally left blank
        end

        Success()
      end

      # @param [Object] set
      # @return [Hash, nil]
      abstract_method!(:prepare_set_from, signature: "set")

      private

      # @return [void]
      def mark_sets_refreshed_at!
        harvest_source.touch(:sets_refreshed_at)
      end

      # @return [<HarvestSet>]
      def process_batch(batch)
        tuples = batch.each_with_object([]) do |set, tups|
          prepared = prepare_set_from(set)

          validated = validate_prepared_set(prepared)

          next if validated.blank?

          tups << validated.merge(harvest_source_id:)
        end.uniq { _1[:identifier] }

        return EMPTY_ARRAY if tuples.blank?

        result = HarvestSet.upsert_all tuples, unique_by: %i[harvest_source_id identifier], returning: :id

        ids = result.pluck("id")

        return HarvestSet.find(ids)
      end

      # @param [Hash] prepared
      # @return [Hash, nil]
      def validate_prepared_set(prepared)
        # simplecov:disable
        return nil if prepared.blank?
        # simplecov:enable

        MeruAPI::Container["harvesting.sets.validate_prepared"].(
          prepared
        ).to_monad.fmap(&:to_h).value_or(nil)
      end
    end
  end
end
