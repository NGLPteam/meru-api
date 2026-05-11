# frozen_string_literal: true

module Support
  module Filtering
    module Inputs
      # A comparator match input for float values.
      #
      # @see ::Support::Filtering::CommonArguments#float_match
      class FloatMatch < ::Support::Filtering::Inputs::ComparatorMatch.of(:float)
      end
    end
  end
end
