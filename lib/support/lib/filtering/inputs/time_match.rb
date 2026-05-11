# frozen_string_literal: true

module Support
  module Filtering
    module Inputs
      # A comparator match input for time values.
      #
      # @see ::Support::Filtering::CommonArguments#time_match
      class TimeMatch < ::Support::Filtering::Inputs::ComparatorMatch.of(:time)
      end
    end
  end
end
