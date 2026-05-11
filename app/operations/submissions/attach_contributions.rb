# frozen_string_literal: true

module Submissions
  # @see Submissions::ContributionsAttacher
  class AttachContributions < Support::SimpleServiceOperation
    service_klass Submissions::ContributionsAttacher
  end
end
