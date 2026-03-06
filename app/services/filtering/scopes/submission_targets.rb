# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {SubmissionTarget}.
    class SubmissionTargets < ::Filtering::FilterScope[::SubmissionTarget]
      simple_state_filter! :submission_target_states

      timestamps!
    end
  end
end
