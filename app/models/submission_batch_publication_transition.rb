# frozen_string_literal: true

# @see SubmissionBatchPublication
class SubmissionBatchPublicationTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :submission_batch_publication_state

  belongs_to :submission_batch_publication, inverse_of: :submission_batch_publication_transitions
  belongs_to :user, inverse_of: :submission_batch_publication_transitions, optional: true

  owner_association_name :submission_batch_publication

  transitions_association_name :submission_batch_publication_transitions
end
