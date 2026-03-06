# frozen_string_literal: true

module Submissions
  # @see Submissions::Publisher
  class Publish < Support::SimpleServiceOperation
    service_klass Submissions::Publisher
  end
end
