# frozen_string_literal: true

module Templates
  module Drops
    # A drop representing an {Ordering}.
    #
    # @see Templates::Drops::OrderingsDrop
    class OrderingDrop < Templates::Drops::AbstractDrop
      # @return [Integer]
      attr_reader :count

      # @return [Templates::Drops::VariablePrecisionDateDrop]
      attr_reader :latest_published

      # @return [Templates::Drops::VariablePrecisionDateDrop]
      attr_reader :oldest_published

      delegate :identifier, :name, to: :@ordering

      # @param [Ordering] ordering
      def initialize(ordering)
        @ordering = ordering

        @count = ordering.visible_count

        @latest_published = Templates::Drops::VariablePrecisionDateDrop.new(@ordering.latest_published)

        @oldest_published = Templates::Drops::VariablePrecisionDateDrop.new(@ordering.oldest_published)
      end
    end
  end
end
