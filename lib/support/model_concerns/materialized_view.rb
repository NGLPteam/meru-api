# frozen_string_literal: true

# A concern for a materialized view-backed model.
#
# @see View
module MaterializedView
  extend ActiveSupport::Concern

  include View

  included do
    extend Dry::Core::ClassAttributes

    defines :refreshes_concurrently, type: Support::Types::Bool

    refreshes_concurrently true
  end

  module ClassMethods
    def populated?
      Scenic.database.populated?(table_name)
    end

    # @return [void]
    def refresh!(concurrently: refreshes_concurrently, cascade: false)
      Scenic.database.refresh_materialized_view(table_name, concurrently:, cascade:)
    end

    # @api private
    # @return [void]
    def refreshes_concurrently!
      refreshes_concurrently true
    end
  end
end
