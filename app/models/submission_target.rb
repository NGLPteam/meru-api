# frozen_string_literal: true

# A child model to an {Entity} that represents a deposit target for a {Submission}.
#
# It contains information about requirements for submitting to the journal / unit / community / etc.
class SubmissionTarget < ApplicationRecord
  include AssignsPolymorphicForeignKey
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  attribute :description, SubmissionTargets::Description.to_type

  pg_enum! :state, as: :submission_target_state, allow_blank: false, default: "closed"
  pg_enum! :deposit_mode, as: :submission_deposit_mode, allow_blank: false, default: "direct", suffix: :deposit

  has_state_machine! predicates: :ALL

  belongs_to :entity, polymorphic: true, inverse_of: :submission_target
  belongs_to :schema_version, inverse_of: :submission_targets

  belongs_to :community, optional: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  has_many_readonly :contextual_single_permissions, primary_key: %i[entity_type entity_id], foreign_key: %i[hierarchical_type hierarchical_id]

  has_many :depositor_requests, dependent: :destroy, inverse_of: :submission_target

  has_many :submission_batch_publications, dependent: :destroy, inverse_of: :submission_target

  has_many :submission_deposit_targets, -> { includes(:entity) }, dependent: :destroy, inverse_of: :submission_target, autosave: true

  has_many :submission_target_reviewers, -> { in_default_order }, dependent: :destroy, inverse_of: :submission_target

  has_many :reviewers, through: :submission_target_reviewers, source: :user

  has_many :submission_target_schema_versions, -> { in_default_order }, dependent: :destroy, inverse_of: :submission_target

  has_many :schema_versions, through: :submission_target_schema_versions

  has_many :submissions, dependent: :nullify, inverse_of: :submission_target

  has_many :submission_reviews, through: :submissions

  scope :in_default_order, -> { order(created_at: :desc) }

  assign_polymorphic_foreign_key! :entity, :community, :collection, :item

  before_validation :inherit_schema_version!

  before_validation :enforce_direct_deposit_target!, if: :direct_deposit?

  before_validation :determine_allowed_child_kinds!

  after_save :prune_mismatched_submission_deposit_targets!

  after_save_commit :check_for_auto_close!, if: :open?

  after_touch :check_for_auto_close!

  validates :description, store_model: true

  validate :must_have_deposit_targets!, on: :opening

  validate :must_have_schema_versions!, on: :opening

  # @param [<Submission>] submissions
  # @param [User, nil] user
  # @see SubmissionTargets::BatchPublisher
  # @return [Dry::Monads::Success(SubmissionBatchPublication)]
  monadic_operation! def batch_publish(*submissions, user: nil)
    call_operation("submission_targets.batch_publish", self, submissions.flatten, user:)
  end

  monadic_operation! def configure(**options)
    call_operation("submission_targets.configure", self, **options)
  end

  def missing_descendant_targets? = descendant_deposit? && !submission_deposit_targets.descendant_deposit.exists?

  private

  # @return [void]
  def check_for_auto_close!
    return unless in_state?(:open) && missing_descendant_targets?

    transition_to!(:closed)
  end

  # @return [void]
  def determine_allowed_child_kinds!
    self.allowed_child_kinds = schema_versions.reorder(kind: :asc).pluck(:kind).uniq
  end

  # @return [void]
  def enforce_direct_deposit_target!
    submission_deposit_targets.where(entity:).first_or_initialize
  end

  # @return [void]
  def inherit_schema_version!
    self.schema_version = entity.schema_version
  end

  # @return [void]
  def prune_mismatched_submission_deposit_targets!
    # :nocov:
    deleted = submission_deposit_targets.where.not(deposit_mode:).delete_all

    return if deleted == 0

    new_deposit_targets_count = submission_deposit_targets.count

    return if deposit_targets_count == new_deposit_targets_count

    update_column(:deposit_targets_count, new_deposit_targets_count)
    # :nocov:
  end

  # @return [void]
  def must_have_deposit_targets!
    errors.add :base, "There must be at least one entity available to deposit" unless submission_deposit_targets.exists?(deposit_mode:)
  end

  # @return [void]
  def must_have_schema_versions!
    errors.add :base, "There must be at least one schema version available for submission" unless submission_target_schema_versions.exists?
  end

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionTarget>]
    def manageable_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      with_contextual_action_for(user, "self.manage_access")
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionTarget>]
    def reviewable_by(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      with_contextual_action_for(user, "self.review")
    end

    def visible_to(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      actions = %w[self.read self.review self.deposit self.update]

      with_contextual_action_for(user, actions)
    end

    private

    # @param [User] user
    # @param [String, <String>] action
    # @return [ActiveRecord::Relation<SubmissionTarget>]
    def with_contextual_action_for(user, action)
      search_scope = SubmissionTarget.joins(:contextual_single_permissions)
        .where(contextual_single_permissions: { user:, action: }).select(arel_table[:id])

      where(id: search_scope)
    end
  end
end
