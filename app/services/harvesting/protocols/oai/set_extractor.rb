# frozen_string_literal: true

module Harvesting
  module Protocols
    module OAI
      # An abstract service used to extract {HarvestSet}s from a {HarvestSource},
      # based on its {HarvestProtocol}, (if available).
      #
      # @abstract
      class SetExtractor < Harvesting::Protocols::SetExtractor
        # @param [String, nil] cursor
        # @return [::OAI::ListSetsResponse]
        def build_batch(cursor: nil)
          if cursor.present?
            # simplecov:disable
            protocol.client.list_sets resumption_token: cursor
            # simplecov:enable
          else
            protocol.client.list_sets
          end
        rescue ::OAI::Exception => e
          logger.fatal("OAI-PMH Provider Error during set extraction: [#{e.code || "unknown"}] #{e.message}")

          halt_enumeration
        end

        # @param [::OAI::ListSetsResponse] batch
        # @return [String, nil]
        def next_cursor_from(batch)
          batch.resumption_token
        end

        # @param [OAI::Set] set
        # @return [Hash]
        def prepare_set_from(set)
          {
            identifier: set.spec,
            name: set.name.presence || set.spec,
            description: set.description.try(:text).presence,
          }.compact
        end
      end
    end
  end
end
