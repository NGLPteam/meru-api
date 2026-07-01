# frozen_string_literal: true

module Harvesting
  module Protocols
    module Pressbooks
      # Extract records from an OAI-PMH feed.
      class RecordBatchExtractor < Harvesting::Protocols::RecordBatchExtractor
        private

        # @param [String, nil] cursor
        # @return [::Protocols::Pressbooks::Books::Response]
        def build_batch(cursor: nil)
          options = options_for(cursor:)

          protocol.client.fetch_books(**options)
        rescue ::Protocols::Pressbooks::Error => e
          # simplecov:disable
          logger.fatal("Pressbooks Provider Error during record extraction: #{e.message}")

          halt_enumeration
          # simplecov:enable
        end

        # @param [::Protocols::Pressbooks::Books::Response] batch
        # @return [String, nil]
        def next_cursor_from(batch)
          batch.resumption_token
        end

        # @param [::Protocols::Pressbooks::Books::Response] batch
        # @return [void]
        def on_initial_batch(batch)
          total_count = total_record_count_for batch

          update_total_record_count! total_count
        end

        # @param [::Protocols::Pressbooks::Books::Response] batch
        # @return [void]
        def on_batch(batch)
          cursor = batch.resumption_token

          count = batch.books.size

          total = harvest_attempt.record_count.to_i.nonzero? || "unknown"

          message = "Extracting #{count}/#{total} record(s)"

          if cursor.present?
            logger.debug "#{message}, cursor: #{cursor}"
          else
            logger.debug "#{message}, no cursor"
          end
        end

        # @param [String, nil] cursor
        def options_for(cursor: nil)
          return options_for_initial_request if cursor.nil?

          ::Protocols::Pressbooks::ResumptionToken.parse(cursor)
        end

        def options_for_initial_request
          {}.tap do |h|
            h[:current_page] = 1
          end
        end

        # @param [::Protocols::Pressbooks::Books::Response] batch
        # @return [Integer, nil]
        def total_record_count_for(batch)
          batch.total_records
        end
      end
    end
  end
end
