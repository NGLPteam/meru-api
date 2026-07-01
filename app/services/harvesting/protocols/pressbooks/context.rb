# frozen_string_literal: true

module Harvesting
  module Protocols
    module Pressbooks
      class Context < Harvesting::Protocols::Context
        after_initialize :build_client!

        # @return [::Protocols::Pressbooks::Client]
        attr_reader :client

        # @param [::Metadata::Pressbooks::Books::Record] record
        def deleted?(record)
          # Not supported by PB
          false
        end

        # @param [::Metadata::Pressbooks::Books::Record] record
        def extract_raw_metadata(record)
          Success record.as_json
        end

        # @param [::Metadata::Pressbooks::Books::Record] record
        def extract_raw_source(record)
          # We don't record a source for pressbooks data. It's just metadata.
          Success nil
        end

        # @param [::Metadata::Pressbooks::Books::Record] record
        def record_identifier_for(record)
          Success record.id
        end

        def perform_check!
          client.check
        rescue Faraday::Error => e
          # simplecov:disable
          check_failed_because! "Web request failed when checking harvest source: #{e.message}"
          # simplecov:enable
        else
          true
        end

        private

        # @see ::Protocols::OAI::BuildClient
        # @return [void]
        def build_client!
          @client = MeruAPI::Container["protocols.pressbooks.build_client_from_source"].(harvest_source).value!
        end
      end
    end
  end
end
