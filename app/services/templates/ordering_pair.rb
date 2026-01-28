# frozen_string_literal: true

module Templates
  # A way of getting at the prev/next siblings for a source entity
  # within a template instance.
  #
  # @see Templates::OrderingInstance
  # @see Templates::Instances::HasOrderingPair
  # @see Types::TemplateHasOrderingPairType
  # @see Types::TemplateOrderingPairType
  class OrderingPair
    include Dry::Core::Constants
    include Dry::Core::Equalizer.new(:instance)
    include Dry::Initializer[undefined: false].define -> do
      param :instance, Templates::Types::TemplateInstance
    end

    # @return [Integer]
    attr_reader :count

    # @return [Boolean]
    attr_reader :exists

    alias exists? exists

    # @return [Boolean]
    attr_reader :first

    alias first? first

    # @return [Boolean]
    attr_reader :last

    alias last? last

    # @return [Boolean]
    attr_reader :has_either_sibling

    alias has_either_sibling? has_either_sibling

    # @return [Boolean]
    attr_reader :in_ordering

    alias in_ordering? in_ordering

    # @return [Boolean]
    attr_reader :only

    alias only? only

    # @return [Integer, nil]
    attr_reader :position

    # @return [HierarchicalEntity, nil]
    attr_reader :prev_sibling

    # @return [HierarchicalEntity, nil]
    attr_reader :next_sibling

    def initialize(...)
      super

      @count = instance.ordering.try(:visible_count) || 0

      @in_ordering = instance.ordering.present? && instance.ordering_entry.present?

      @position = instance.ordering_entry&.position

      @prev_sibling = instance.prev_sibling

      @next_sibling = instance.next_sibling

      @first = in_ordering? && prev_sibling.blank?
      @last = in_ordering? && next_sibling.blank?
      @only = first? && last?

      @has_either_sibling = @prev_sibling.present? || @next_sibling.present?

      @exists = in_ordering? && has_either_sibling?
    end
  end
end
