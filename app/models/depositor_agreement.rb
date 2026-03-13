# frozen_string_literal: true

# A depositor agreement marks the user's acceptance of the terms for submitting
# to a given {SubmissionTarget}. Its state is tracked so that we can reset it if
# the terms change and require users to re-accept.
#
# @see DepositorAgreementTransition
# @see DepositorAgreements::StateMachine
class DepositorAgreement < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  pg_enum! :state, as: :depositor_agreement_state, allow_blank: false, default: "pending"

  has_state_machine!

  belongs_to :submission_target, inverse_of: :depositor_agreements

  belongs_to :user, inverse_of: :depositor_agreements

  # @see DepositorAgreements::Accept
  # @see DepositorAgreements::Accepter
  # @return [Dry::Monads::Success(DepositorAgreement)]
  monadic_operation! def accept
    call_operation("depositor_agreements.accept", depositor_agreement: self)
  end

  # @see DepositorAgreements::Reset
  # @see DepositorAgreements::Resetter
  # @return [Dry::Monads::Success(DepositorAgreement)]
  monadic_operation! def reset
    call_operation("depositor_agreements.reset", depositor_agreement: self)
  end

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<DepositorAgreement>]
    def owned_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?
      # :nocov:

      where(user:)
    end

    # Reset all accepted agreements to `pending`.
    #
    # @return [void]
    def reset_all!
      in_state(:accepted).find_each(&:reset!)
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<DepositorAgreement>]
    def reviewable_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      where(submission_target: SubmissionTarget.reviewable_by(user))
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<DepositorAgreement>]
    def visible_to(user)
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?

      owned = arel_expr_in_query(arel_table[:id], owned_by(user).select(:id))
      reviewable = arel_expr_in_query(arel_table[:id], reviewable_by(user).select(:id))

      where(owned.or(reviewable))
    end
  end
end
