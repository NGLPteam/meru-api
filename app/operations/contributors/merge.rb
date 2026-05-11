# frozen_string_literal: true

module Contributors
  # @see Contributors::Merger
  class Merge < Support::SimpleServiceOperation
    service_klass Contributors::Merger
  end
end
