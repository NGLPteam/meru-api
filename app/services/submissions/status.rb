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

    # @return [Boolean]
    attr_reader :any_published

    alias any_published? any_published

    # @return [Boolean]
    attr_reader :current

    alias current? current

    # @return [Boolean]
    attr_reader :locked_state

    alias locked_state? locked_state

    # @return [Boolean]
    attr_reader :mutable_state

    alias mutable_state? mutable_state

    def initialize(...)
      super

      @any_published = from_state == "published" || to_state == "published"

      @current = from_state == to_state

      @locked_state = to_state.in?(LOCKED_STATES)

      @mutable_state = to_state.in?(MUTABLE_STATES)
    end

    class << self
      # @return [Class]
      def policy_class = Submissions::StatusPolicy
    end

    # @return [Class]
    def policy_class = self.class.policy_class
  end
end
