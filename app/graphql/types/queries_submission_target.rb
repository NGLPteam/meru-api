# frozen_string_literal: true

module Types
  # An interface for querying {SubmissionTarget}.
  module QueriesSubmissionTarget
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `SubmissionTarget` records.
    TEXT

    field :submission_target, ::Types::SubmissionTargetType, null: true do
      description <<~TEXT
      Retrieve a single `SubmissionTarget` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :submission_targets, resolver: ::Resolvers::SubmissionTargetResolver do
      description <<~TEXT
      Retrieve a list of `SubmissionTarget` records, optionally filtered by various criteria.
      TEXT
    end

    # @param [String] slug
    # @return [SubmissionTarget, nil]
    def submission_target(slug:)
      load_record_with(SubmissionTarget, slug)
    end
  end
end
