# frozen_string_literal: true

module Support
  module Requests
    # An extension that wraps connection resolution to allow us to track whether
    # that search matched an identifier exactly, and if so, allow the frontend
    # to process the result in a different fashion.
    #
    # @api private
    class ConnectionCounts < GraphQL::Schema::FieldExtension
      extras %i[lookahead]

      # @return [void]
      def resolve(object:, arguments:, context:, **)
        arguments => { lookahead: }

        pagination = lookahead.selection(:page_info)

        wants_total_count = pagination.selects?(:total_count)

        wants_unfiltered_count = pagination.selects?(:total_unfiltered_count)

        current_path = context[:current_path] || ConnectionInfo::UNKNOWN_PATH

        options = { path: current_path, wants_total_count:, wants_unfiltered_count: }

        info = Support::Requests::ConnectionInfo.new(**options)

        Support::Requests::CurrentConnection.set(info:, current_path:) do
          yield object, arguments, info
        end
      end

      # @param [GraphQL::Pagination::Connection] value
      # @param [Lookups::Lookup, nil] memo
      # @return [GraphQL::Pagination::Connection]
      def after_resolve(value:, context:, memo: nil, **)
        context.scoped_set!(:connection_info, memo)

        return value
      end
    end
  end
end
