# frozen_string_literal: true

module Templates
  module Drops
    # @abstract
    class AbstractContributionsDrop < Templates::Drops::AbstractDrop
      include Enumerable

      # @return [Boolean]
      attr_reader :exists

      # @return [Boolean]
      attr_reader :missing

      # @param [HierarchicalEntity] entity
      def initialize(entity)
        @entity = entity

        @contributions = fetch_contributions.map(&:to_liquid)

        @exists = @contributions.any?

        @missing = !@exists
      end

      def each
        # :nocov:
        return enum_for(__method__) unless block_given?
        # :nocov:

        @contributions.each do |contribution|
          yield contribution
        end
      end

      def to_s
        @contributions.map(&:display_name).to_sentence
      end

      private

      # @abstract
      # @return [ActiveRecord::Relation<::Contribution>]
      def fetch_contributions
        @entity.contributions.includes(:contributor)
      end
    end
  end
end
