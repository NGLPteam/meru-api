# frozen_string_literal: true

module Types
  # An interface for querying {SubmissionTargetReviewer}.
  module QueriesSubmissionTargetReviewer
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `SubmissionTargetReviewer` records.
    TEXT

    field :submission_target_reviewer, ::Types::SubmissionTargetReviewerType, null: true do
      description <<~TEXT
      Retrieve a single `SubmissionTargetReviewer` by slug.
      TEXT

      argument :slug, Support::GQL::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :submission_target_reviewers, resolver: ::Resolvers::SubmissionTargetReviewerResolver

    # @param [String] slug
    # @return [SubmissionTargetReviewer, nil]
    def submission_target_reviewer(slug:)
      load_record_with(SubmissionTargetReviewer, slug)
    end
  end
end
