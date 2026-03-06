# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {SubmissionComment}.
    class SubmissionComments < ::Filtering::FilterScope[::SubmissionComment]
      timestamps!
    end
  end
end
