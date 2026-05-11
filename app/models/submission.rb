# frozen_string_literal: true

# A model representing a deposit into Meru, created by a {User} with `deposit` permission against a {SubmissionTarget}.
class Submission < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  pg_enum! :state, as: :submission_state, allow_blank: false, default: "draft"
  pg_enum! :kind, as: :child_entity_kind, allow_blank: false

  has_state_machine! predicates: :ALL

  has_many :submission_comments, -> { in_default_order }, dependent: :destroy, inverse_of: :submission

  has_many :submission_publications, -> { in_recent_order }, inverse_of: :submission, dependent: :destroy

  has_many :submission_reviews, inverse_of: :submission, dependent: :destroy

  belongs_to :submission_target, inverse_of: :submissions, optional: true

  belongs_to :schema_version, inverse_of: :submissions

  belongs_to :user, inverse_of: :submissions

  belongs_to :parent_entity, polymorphic: true, inverse_of: :child_submissions, optional: true

  belongs_to :entity, polymorphic: true, inverse_of: :submission, optional: true

  scope :in_default_order, -> { order(created_at: :desc) }

  define_simple_lookups! :schema_version, :user, :parent_entity, :submission_target

  strip_attributes only: %i[title]

  before_validation :derive_kind!

  after_create :construct_draft_entity!

  validates :entity_id, uniqueness: { scope: :entity_type, if: :entity_id? }

  # @!attribute [rw] agreement_accepted
  # @return [Boolean]
  def agreement_accepted = agreement_accepted_at?

  alias agreement_accepted? agreement_accepted

  def agreement_accepted=(value)
    # :nocov:
    self.agreement_accepted_at ||= Time.current if ActiveRecord::Type::Boolean.new.cast(value)
    # :nocov:
  end

  # @see Submissions::AttachContributions
  # @see Submissions::ContributionsAttacher
  # @return [Dry::Monads::Result]
  monadic_operation! def attach_contributions
    call_operation("submissions.attach_contributions", self)
  end

  # @note Called during rejection.
  # @see Submissions::Cleaner
  # @see Submissions::CleanUp
  # @return [Dry::Monads::Result]
  monadic_operation! def clean_up
    call_operation("submissions.clean_up", self)
  end

  # @see Submissions::ConstructDraftEntity
  # @see Submissions::DraftEntityConstructor
  # @return [Dry::Monads::Result]
  monadic_operation! def construct_draft_entity
    call_operation("submissions.construct_draft_entity", self)
  end

  # @return [<Submissions::Status>]
  def available_transitions
    state_machine.allowed_transitions.map do |to_state|
      status_for(to_state)
    end
  end

  # @return [Submissions::Status]
  def current_status = Submissions::Status.new(self)

  # @see Submissions::EnforceAuthor
  # @see Submissions::AuthorEnforcer
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def enforce_author
    call_operation("submissions.enforce_author", self)
  end

  # @see Submissions::Publish
  # @see Submissions::Publisher
  # @return [Dry::Monads::Result]
  monadic_operation! def publish(**options)
    call_operation("submissions.publish", self, **options)
  end

  # @param [String] to_state
  # @return [Submissions::Status]
  def status_for(to_state) = Submissions::Status.new(self, to_state:)

  private

  # @return [void]
  def derive_kind!
    self.kind = schema_version.kind
  end

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<Submission>]
    def owned_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?
      # :nocov:

      where(user:)
    end

    def search_by_prefix(...)
      where(entity_id: EntitySearchDocument.search_by_prefix(...).select(:entity_id))
    end

    def search_by_query(...)
      where(entity_id: EntitySearchDocument.search_by_query(...).select(:entity_id))
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<Submission>]
    def reviewable_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      where(submission_target: SubmissionTarget.reviewable_by(user))
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<Submission>]
    def visible_to(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      owned = arel_expr_in_query(arel_table[:id], owned_by(user).select(:id))
      reviewable = arel_expr_in_query(arel_table[:id], reviewable_by(user).select(:id))

      where(owned.or(reviewable))
    end
  end
end
