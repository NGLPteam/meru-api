# frozen_string_literal: true

module Support
  module Requests
    # @api private
    class ConnectionInfo < Support::WritableStruct
      UNKNOWN_PATH = %w[unknown].freeze

      attribute :path, Types::Path

      attribute? :total_count, Types::Count
      attribute? :unfiltered_count, Types::Count

      attribute? :wants_total_count, Types::Bool.default(false)
      attribute? :wants_unfiltered_count, Types::Bool.default(false)

      alias wants_total_count? wants_total_count
      alias wants_unfiltered_count? wants_unfiltered_count

      class << self
        # @return [ConnectionInfo]
        def unknown
          new(path: UNKNOWN_PATH)
        end
      end
    end
  end
end
