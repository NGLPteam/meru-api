# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {SubmissionTargetReviewer}.
    class SubmissionTargetReviewers < ::Filtering::FilterScope[::SubmissionTargetReviewer]
      simple_scope_filter! :submission_target, :submission_targets do |arg|
        arg.description <<~TEXT
        Filter by the submission target.
        TEXT
      end

      simple_scope_filter! :user, :users do |arg|
        arg.description <<~TEXT
        Filter by the associated user.
        TEXT
      end

      timestamps!
    end
  end
end
