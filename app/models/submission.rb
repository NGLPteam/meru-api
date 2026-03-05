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

  belongs_to :submission_target, inverse_of: :submissions, optional: true

  belongs_to :schema_version, inverse_of: :submissions

  belongs_to :user, inverse_of: :submissions

  belongs_to :parent_entity, polymorphic: true, inverse_of: :child_submissions, optional: true

  belongs_to :entity, polymorphic: true, inverse_of: :submission, optional: true

  define_simple_lookups! :schema_version, :user, :parent_entity, :submission_target

  before_validation :derive_kind!

  after_create :create_draft_entity!

  validates :entity_id, uniqueness: { scope: :entity_type, if: :entity_id? }

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

      owned = arel_expr_in_query(:id, owned_by(user).select(:id))
      reviewable = arel_expr_in_query(:id, reviewable_by(user).select(:id))

      where(owned.or(reviewable))
    end
  end
end
