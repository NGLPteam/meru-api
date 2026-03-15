# frozen_string_literal: true

module Harvesting
  module Protocols
    module OAI
      class Context < Harvesting::Protocols::Context
        after_initialize :build_client!

        # @return [::OAI::Client]
        attr_reader :client

        # @param [OAI::Record] record
        def deleted?(record)
          record.header.status == "deleted"
        end

        # @param [OAI::Record] record
        # @return [Dry::Monads::Success(String)]
        def extract_raw_metadata(record)
          metadata = record.metadata

          return Success(nil) if metadata.nil?

          if metadata.elements.size == 1
            Success metadata.elements.first.to_s
          elsif metadata.children.any?
            Success metadata.children.join.strip
          else
            # :nocov:
            Failure[:invalid_metadata, "expected metadata to have at least 1 child"]
            # :nocov:
          end
        end

        # @param [OAI::Record] record
        # @return [Dry::Monads::Success(String)]
        def extract_raw_source(record)
          Success record._source.to_s
        end

        # @param [OAI::Record] record
        # @return [Dry::Monads::Success(String)]
        # @return [Dry::Monads::Failure(:no_record_identifier, OAI::Record)]
        def record_identifier_for(record)
          identifier = record.try(:header).try(:identifier)

          # :nocov:
          return Failure[:no_record_identifier, record] if identifier.blank?
          # :nocov:

          Success(identifier)
        end

        def perform_check!
          client.identify
        rescue Faraday::Error => e
          # :nocov:
          check_failed_because! "Web request failed when checking harvest source: #{e.message}"
          # :nocov:
        rescue ::OAI::Exception => e
          check_failed_because! "OAI PMH Server had a bad response [#{e.code || "unknown code"}]: #{e.message}"
        else
          true
        end

        # Skip OAI records that are missing metadata for some reason.
        # @param [OAI::Record] record
        def skip?(record)
          super || record.metadata.blank?
        end

        private

        # @see ::Protocols::OAI::BuildClient
        # @return [void]
        def build_client!
          @client = MeruAPI::Container["protocols.oai.build_client_from_source"].(harvest_source).value!
        end
      end
    end
  end
end
