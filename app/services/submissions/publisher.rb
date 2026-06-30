# frozen_string_literal: true

module Submissions
  # @see Submissions::Publish
  # @see Submissions::PublishJob
  class Publisher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :submission, Submissions::Types::Submission

      option :submission_publication, Submissions::Types::SubmissionPublication.optional, optional: true, as: :provided_publication

      option :user, Submissions::Types::User.optional, optional: true
    end

    standard_execution!

    delegate :entity, to: :submission

    # @return [Role]
    attr_reader :author_role

    # @return [SubmissionPublication]
    attr_reader :submission_publication

    # @return [Dry::Monads::Success(SubmissionPublication)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield publish_entity!
      end

      Success submission_publication
    end

    wrapped_hook! def prepare
      @submission_publication = provided_publication || submission.submission_publications.find_or_create_by!(user:)

      @author_role = Role.fetch(:author)

      super
    end

    wrapped_hook! def try_to_publish
      actually_publish_entity!

      prune_pending_reviews!

      handle_state_transitions!

      remove_author_role!

      super
    end

    around_try_to_publish :wrap_in_transaction!

    wrapped_hook! def publish_entity
      yield try_to_publish!

      super
    rescue StandardError => e
      submission_publication.transition_to(:failure, reason: e.message)

      super
    end

    private

    # @return [void]
    def actually_publish_entity!
      entity.published ||= VariablePrecisionDate.parse(Date.current)

      entity.submission_status = "submission_published"

      entity.visibility = :visible

      entity.save!
    end

    # @return [void]
    def handle_state_transitions!
      submission_publication.transition_to!(:success)

      submission.transition_to!(:published)
    end

    # @return [void]
    def prune_pending_reviews!
      SubmissionReview.pending.where(submission:).find_each do |review|
        review.destroy!
      end
    end

    # @return [void]
    def remove_author_role!
      MeruAPI::Container["access.revoke"].(author_role, on: entity, to: submission.user)
    end

    def wrap_in_transaction!
      ActiveRecord::Base.transaction do
        yield
      end
    end
  end
end
