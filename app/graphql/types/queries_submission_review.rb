# frozen_string_literal: true

module Types
  # An interface for querying {SubmissionReview}.
  module QueriesSubmissionReview
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `SubmissionReview` records.
    TEXT

    field :submission_review, ::Types::SubmissionReviewType, null: true do
      description <<~TEXT
      Retrieve a single `SubmissionReview` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :submission_reviews, resolver: ::Resolvers::SubmissionReviewResolver

    # @param [String] slug
    # @return [SubmissionReview, nil]
    def submission_review(slug:)
      load_record_with(SubmissionReview, slug)
    end
  end
end
