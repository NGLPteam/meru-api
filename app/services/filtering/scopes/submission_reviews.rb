# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {SubmissionReview}.
    class SubmissionReviews < ::Filtering::FilterScope[::SubmissionReview]
      simple_state_filter! :submission_review_states

      simple_scope_filter! :submission, :submissions

      simple_scope_filter! :user, :users

      timestamps!
    end
  end
end
