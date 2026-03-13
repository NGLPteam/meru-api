# frozen_string_literal: true

module Submissions
  # @see Submissions::Status
  class StatusPolicy < ApplicationPolicy
    pre_check :deny_anonymous!

    pre_check :deny_published!

    pre_check :guard_locked!, only: %i[update? transition?]

    delegate :mutable_state?, :locked_state?, to: :record, prefix: :in

    delegate :to_state, to: :record

    def update? = in_mutable_state?

    def transition? = deposit?

    private

    def can_transition_locked? = in_locked_state? && manage?

    # Whether the current user has permission to deposit on the {SubmissionTarget}.
    #
    # @see SubmissionTargetPolicy#deposit?
    def deposit? = allowed_to?(:deposit?, record.submission_target)

    # Published states must be handled through the publish mutations.
    #
    # @return [void]
    def deny_published!
      deny! if record.any_published?
    end

    # @return [void]
    def guard_locked!
      allow! if can_transition_locked?

      deny! if in_locked_state?
    end

    # Whether the current user has permission to update the submission target entity.
    #
    # @see HierarchicalEntityPolicy#update?
    def manage? = allowed_to?(:update?, record.target_entity)
  end
end
