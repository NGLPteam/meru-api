# frozen_string_literal: true

module Protocols
  module Pressbooks
    module PaginatedResponse
      extend ActiveSupport::Concern

      TOTAL_PAGES_HEADER = "x-wp-totalpages"

      TOTAL_RECORDS_HEADER = "x-wp-total"

      included do
        paginated true

        before_initialize :prepare_pagination_data!

        after_initialize :parse_pagination_data!

        delegate :current_page, :has_more?, :more?, :total_pages, :total_records, to: :pagination
      end

      # @return [Protocols::Pressbooks::AbstractResponse, nil]
      def next_page
        # simplecov:disable
        raise "nothing to fetch" unless more?
        # simplecov:enable

        request.next_page.()
      end

      # @return [String, nil]
      def resumption_token
        # simplecov:disable
        return unless more?
        # simplecov:enable

        @resumption_token ||= build_resumption_token
      end

      # @return [Protocols::Pressbooks::Pagination]
      attr_reader :pagination

      # @api private
      # @return [void]
      def prepare_pagination_data!
        @pagination = Protocols::Pressbooks::Pagination.new
      end

      # @api private
      # @return [void]
      def parse_pagination_data!
        @pagination.current_page = request.current_page

        @pagination.total_pages = raw_response.headers[TOTAL_PAGES_HEADER].to_i

        @pagination.total_records = raw_response.headers[TOTAL_RECORDS_HEADER].to_i
      end

      private

      # @return [String]
      def build_resumption_token
        ::Protocols::Pressbooks::ResumptionToken.new(current_page: current_page + 1).to_cursor
      end
    end
  end
end
