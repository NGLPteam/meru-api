# frozen_string_literal: true

module Resolvers
  module Enhancements
    # Sometimes we need to modify the results query. search_object does not provide
    # a hook for that, but it's easy to override
    module FinalizesResults
      extend ActiveSupport::Concern

      # @api private
      # This method comes from search_object and generates the initial query, with
      # all options applied. We hook into it in order to apply any finalizations
      # our specific resolver needs.
      #
      # @return [ActiveRecord::Relation]
      def fetch_results
        finalize super
      end

      # @api private
      # @abstract Override this method
      # @param [ActiveRecord::Relation] scope
      # @return [ActiveRecord::Relation]
      def finalize(scope)
        scope.all
      end
    end
  end
end
