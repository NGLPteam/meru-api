# frozen_string_literal: true

# A submission batch publication represents the actual process of publishing multiple {Submission}s
# within a single {SubmissionTarget}.
#
# It groups together multiple {SubmissionPublication}s, which each represent the publication of
# a single {Submission}.
#
# The user associated with the publication is the user that initiated the process,
# if applicable. In some cases, we may not have a user if we implement automated processes.
#
# @see SubmissionBatchPublications::StateMachine
# @see SubmissionBatchPublicationTransition
class SubmissionBatchPublication < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  pg_enum! :state, as: :submission_batch_publication_state, allow_blank: false, default: "pending"

  has_state_machine!

  belongs_to :submission_target, inverse_of: :submission_batch_publications

  belongs_to :user, inverse_of: :submission_batch_publications, optional: true

  has_many :submission_publications, -> { in_batch_order }, inverse_of: :submission_batch_publication, dependent: :restrict_with_error

  define_simple_lookups! :submission_target, :user

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionBatchPublication>]
    def visible_to(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      where(submission_target: SubmissionTarget.visible_to(user))
    end
  end
end
