# frozen_string_literal: true

module Support
  module Migrations
    module QuotationHelpers
      delegate :quote_table_name, :quote_column_name, to: :connection

      # @todo Replace this with engine connection once this is extracted.
      def connection = ApplicationRecord.connection
    end
  end
end
