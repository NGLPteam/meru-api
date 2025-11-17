# frozen_string_literal: true

module Support
  module Requests
    # A concern to set and manage connection info within GraphQL requests.
    module SetsConnectionInfo
      extend ActiveSupport::Concern

      included do
        delegate :wants_total_count?, :wants_unfiltered_count?, to: :connection_info
      end

      def increment_total_count!(value)
        connection_info.total_count += value
      end

      def increment_unfiltered_count!(value)
        connection_info.unfiltered_count += value
      end

      private

      # @!attribute [r] connection_info
      # @see Support::Requests::CurrentConnection.info
      # @return [Support::Requests::ConnectionInfo]
      def connection_info
        Support::Requests::CurrentConnection.info
      end
    end
  end
end
