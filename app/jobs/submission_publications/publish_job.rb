# frozen_string_literal: true

module SubmissionPublications
  # @see SubmissionPublication#publish
  # @see SubmissionPublications::Publish
  # @see SubmissionPublications::Publisher
  class PublishJob < ApplicationJob
    queue_as :depositing

    # @param [SubmissionPublication] submission_publication
    # @return [void]
    def perform(submission_publication)
      submission_publication.publish!
    end
  end
end
