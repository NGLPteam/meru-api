# frozen_string_literal: true

module Contributors
  # @see Contributors::MergeChecker
  class CheckMerge < Support::SimpleServiceOperation
    service_klass Contributors::MergeChecker
  end
end
