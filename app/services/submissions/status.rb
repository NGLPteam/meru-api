# frozen_string_literal: true

module Submissions
  # Status information about the submission's current state.
  class Status
    include Support::Typing
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Types::Submission

      option :from_state, Types::State, default: proc { submission.current_state }

      option :to_state, Types::State, default: proc { submission.current_state }
    end

    delegate :submission_target, to: :submission

    delegate :entity, to: :submission_target, prefix: :target

    MUTABLE_STATES = %w[
      draft
      revision_requested
    ].freeze

    LOCKED_STATES = %w[
      under_review
      approved
      rejected
      published
    ].freeze

    def mutable_state? = to_state.in?(MUTABLE_STATES)

    alias mutable_state mutable_state?

    def locked_state? = to_state.in?(LOCKED_STATES)

    alias locked_state locked_state?

    class << self
      # @return [Class]
      def policy_class = SubmissionStatusPolicy
    end

    # @return [Class]
    def policy_class = self.class.policy_class
  end
end
