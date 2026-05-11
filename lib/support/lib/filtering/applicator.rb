# frozen_string_literal: true

module Support
  module Filtering
    class Applicator
      include Dry::Core::Equalizer.new(:filters)

      include Dry::Initializer[undefined: false].define -> do
        param :filters, ::Support::Filtering::AbstractScope::Type
      end

      # @param [ActiveRecord::Relation] top_level_scope
      # @return [ActiveRecord::Relation]
      def call(top_level_scope)
        filtered = top_level_scope.where(top_level_scope.primary_key => filtered_scope)

        filters.apply_ranking_to filtered
      end

      # @api private
      # @return [ActiveRecord::Relation]
      def filtered_scope
        @filtered_scope ||= filters.call
      end
    end
  end
end
