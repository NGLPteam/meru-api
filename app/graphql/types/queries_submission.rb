# frozen_string_literal: true

module Types
  # An interface for querying {Submission}.
  module QueriesSubmission
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `Submission` records.
    TEXT

    field :submission, ::Types::SubmissionType, null: true do
      description <<~TEXT
      Retrieve a single `Submission` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :submissions, resolver: ::Resolvers::SubmissionResolver do
      description <<~TEXT
      Retrieve a list of `Submission` records, optionally filtered by various criteria.
      TEXT
    end

    # @param [String] slug
    # @return [Submission, nil]
    def submission(slug:)
      load_record_with(Submission, slug)
    end
  end
end
