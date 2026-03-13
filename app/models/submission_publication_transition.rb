# frozen_string_literal: true

# @see SubmissionPublication
class SubmissionPublicationTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :submission_publication_state

  belongs_to :submission_publication, inverse_of: :submission_publication_transitions
  belongs_to :user, inverse_of: :submission_publication_transitions, optional: true

  owner_association_name :submission_publication

  transitions_association_name :submission_publication_transitions
end
