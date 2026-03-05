# frozen_string_literal: true

module Types
  # An interface for querying {SubmissionComment}.
  module QueriesSubmissionComment
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `SubmissionComment` records.
    TEXT

    field :submission_comment, ::Types::SubmissionCommentType, null: true do
      description <<~TEXT
      Retrieve a single `SubmissionComment` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :submission_comments, resolver: ::Resolvers::SubmissionCommentResolver do
      description <<~TEXT
      Retrieve a list of `SubmissionComment` records, optionally filtered by `submission`.
      TEXT
    end

    # @param [String] slug
    # @return [SubmissionComment, nil]
    def submission_comment(slug:)
      load_record_with(SubmissionComment, slug)
    end
  end
end
