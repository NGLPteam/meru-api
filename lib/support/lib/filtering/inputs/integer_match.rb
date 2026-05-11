# frozen_string_literal: true

module Support
  module Filtering
    module Inputs
      # A comparator match input for integer values.
      #
      # @see ::Support::Filtering::CommonArguments#integer_match
      class IntegerMatch < ::Support::Filtering::Inputs::ComparatorMatch.of(:integer)
      end
    end
  end
end
