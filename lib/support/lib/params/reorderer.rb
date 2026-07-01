# frozen_string_literal: true

module Support
  module Params
    # @api private
    class Reorderer
      include Enumerable

      EMPTY = proc { [] }

      EVERYTHING = Object.new.freeze

      include Dry::Initializer[undefined: false].define -> do
        option :start, Types::ParamList, default: EMPTY
        option :final, Types::ParamList, default: EMPTY
      end

      # @param [Array, Hash] input
      # @return [Array, Hash]
      def call(input)
        case input
        when Types::ParamList
          reorder_list input
        when Types::ParamMap
          reorder_map input
        else
          raise ArgumentError, "Don't know how to reorder #{input.inspect}"
        end
      end

      # @!group Ordering Commands

      def prepend!(*new_values)
        add_values! new_values, direction: :before, reference: EVERYTHING
      end

      def append!(*new_values)
        add_values! new_values, direction: :after, reference: EVERYTHING
      end

      def put!(*new_values, before: nil, after: nil)
        unless before.present? ^ after.present?
          raise "Must specify before XOR after"
        end

        direction = before.present? ? :before : :after

        reference = before.present? ? Types::Param[before] : Types::Param[after]

        add_values!(new_values, direction:, reference:)

        return self
      end

      # @!endgroup

      # @return [String]
      def inspect
        # simplecov:disable
        inspect_order = order.map do |value|
          case value
          when EVERYTHING then :everything.inspect
          else
            value.inspect
          end
        end.join(", ")

        "#{self.class.name}([%<inspect_order>s])" % { inspect_order: }
        # simplecov:enable
      end

      private

      def add_values!(new_values, direction: :after, reference: EVERYTHING)
        to_add = Types::ParamList[new_values.flatten]

        to_add.each do |value|
          # if we're reordering something that already exists, let's remove it first
          order.delete value
        end

        reference_index = order.index reference

        raise "Unknown reference: #{direction}(#{reference.inspect})" if reference_index.nil?

        order.insert reference_index, to_add

        order.flatten!
      end

      def initialize_order
        conflicts = start.intersection final

        unless conflicts.empty?
          raise "overlapping elements in start and final: #{conflicts.inspect}"
        end

        [*start, EVERYTHING, *final]
      end

      def order
        @order ||= initialize_order
      end

      def reorder_list(arr)
        everything_index = order.index(EVERYTHING)

        arr.sort_by do |value|
          param = Types::Param[value]

          index = order.index(param) || everything_index

          [index, param]
        end
      end

      def reorder_map(hsh)
        reorder_list(hsh.keys).index_with do |key|
          hsh.fetch key
        end
      end

      class << self
        # @return [Support::Params::Reorderer]
        def default
          new(
            start: %w[filters or_filters],
            final: %w[order]
          )
        end
      end
    end
  end
end
