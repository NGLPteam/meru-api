# frozen_string_literal: true

module LiquidExt
  # Filters common to multiple Liquid contexts
  module CommonFilters
    WHOLE_NUMBER_MATCH = /\A-?\d+\z/

    # @param [Integer, String] input
    # @return [Boolean]
    def is_whole_number(input)
      case input
      when Integer, WHOLE_NUMBER_MATCH then true
      else
        false
      end
    end

    # @param [#to_s] input
    # @return [String]
    def parameterize(input)
      input.to_s.parameterize
    end
  end
end
