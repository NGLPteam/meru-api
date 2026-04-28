# frozen_string_literal: true

module Submissions
  # @see Submissions::Cleaner
  class CleanUp < Support::SimpleServiceOperation
    service_klass Submissions::Cleaner
  end
end
