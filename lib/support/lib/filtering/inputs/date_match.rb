# frozen_string_literal: true

module Support
  module Filtering
    module Inputs
      # A comparator match input for date values.
      #
      # @see ::Support::Filtering::CommonArguments#date_match
      class DateMatch < ::Support::Filtering::Inputs::ComparatorMatch.of(:date)
      end
    end
  end
end
