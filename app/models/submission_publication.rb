# frozen_string_literal: true

# A submission publication represents the actual process of publishing a {Submission}.
# Since publication can happen in the background and may fail in odd circumstances, we
# need a record outside of the {Submission} itself to capture that nuance.
#
# The user associated with the publication is the user that initiated the process,
# if applicable. In some cases, we may not have a user if we implement automated processes.
#
# @see SubmissionPublications::StateMachine
# @see SubmissionPublicationTransition
class SubmissionPublication < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  pg_enum! :state, as: :submission_publication_state, allow_blank: false, default: "pending"

  has_state_machine!

  belongs_to :submission, inverse_of: :submission_publications

  belongs_to :user, inverse_of: :submission_publications, optional: true

  belongs_to :submission_batch_publication, inverse_of: :submission_publications, optional: true, counter_cache: :publications_count

  define_simple_lookups! :submission, :user, :submission_batch_publication

  scope :in_batch_order, -> { order(batch_position: :asc, created_at: :asc) }

  # A wrapper around {Submissions::Publisher}.
  #
  # @see Submission#publish
  # @see SubmissionPublications::Publish
  # @see SubmissionPublications::Publisher
  # @return [Dry::Monads::Success(SubmissionPublication)]
  monadic_operation! def publish
    call_operation("submission_publications.publish", self)
  end

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionPublication>]
    def visible_to(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      where(submission: Submission.visible_to(user))
    end
  end
end
