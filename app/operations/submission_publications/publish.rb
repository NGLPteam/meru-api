# frozen_string_literal: true

module SubmissionPublications
  # @see SubmissionPublications::Publisher
  class Publish < Support::SimpleServiceOperation
    service_klass SubmissionPublications::Publisher
  end
end
