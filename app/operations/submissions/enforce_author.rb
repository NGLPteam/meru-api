# frozen_string_literal: true

module Submissions
  # @see Submissions::AuthorEnforcer
  class EnforceAuthor < Support::SimpleServiceOperation
    service_klass Submissions::AuthorEnforcer
  end
end
