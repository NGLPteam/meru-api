# frozen_string_literal: true

class User < ApplicationRecord
  include AccessGrantSubject
  include HasSystemSlug
  include ImageUploader::Attachment.new(:avatar)
  include TimestampScopes

  pg_enum! :access_management, as: :access_management, suffix: :access_management

  has_one_readonly :access_info, class_name: "UserAccessInfo", inverse_of: :user

  has_many :community_memberships, dependent: :destroy, inverse_of: :user

  has_many :communities, through: :community_memberships

  has_many_readonly :contextual_permissions, inverse_of: :user

  has_many :user_group_memberships, dependent: :destroy, inverse_of: :user

  has_many :user_groups, through: :user_group_memberships

  has_many :depositor_agreements, inverse_of: :user, dependent: :destroy

  has_many :depositor_agreement_transitions, dependent: :nullify, inverse_of: :user

  has_many :depositor_requests, inverse_of: :user, dependent: :restrict_with_error

  has_many :depositor_request_transitions, dependent: :nullify, inverse_of: :user

  has_many :submissions, inverse_of: :user, dependent: :restrict_with_error

  has_many :submission_batch_publications, inverse_of: :user, dependent: :nullify

  has_many :submission_batch_publication_transitions, inverse_of: :user, dependent: :nullify

  has_many :submission_comments, inverse_of: :user, dependent: :restrict_with_error

  has_many :submission_publications, inverse_of: :user, dependent: :nullify

  has_many :submission_publication_transitions, inverse_of: :user, dependent: :nullify

  has_many :submission_reviews, inverse_of: :user, dependent: :restrict_with_error

  has_many :submission_review_transitions, inverse_of: :user, dependent: :nullify

  has_many :submission_target_reviewers, inverse_of: :user, dependent: :restrict_with_error

  has_many :submission_target_transitions, dependent: :nullify, inverse_of: :user

  has_many :submission_transitions, dependent: :nullify, inverse_of: :user

  validates :keycloak_id, presence: true

  attribute :global_access_control_list, Roles::GlobalAccessControlList.to_type

  before_validation :set_allowed_actions!

  after_create :assign_global_permissions!

  after_save :synchronize_access_info!

  scope :global_admins, -> { where(arel_has_realm_role(:global_admin)) }
  scope :testing, -> { where_contains(email: "@example.") }
  scope :by_role_priority, -> { order(role_priority: :desc) }
  scope :by_inverse_role_priority, -> { order(role_priority: :asc) }

  delegate :permissions, to: :global_access_control_list

  def anonymous? = false

  def authenticated? = true

  # @return [User]
  def authenticated = self

  # @param [HierarchicalEntity] entity
  # @return [ContextualPermission, nil]
  def contextual_permissions_for(entity) = ContextualPermission.fetch(self, entity)

  def has_allowed_action?(name) = name.to_s.in?(allowed_actions)

  def has_role?(name) = name.to_s.in? roles

  def has_global_admin_access? = has_role? :global_admin

  def has_any_upload_access? = has_global_admin_access? || has_granted_asset_creation?

  def system_slug_id = keycloak_id

  # @!scope private
  # @return [void]
  def set_allowed_actions!
    self.allowed_actions = global_access_control_list.allowed_actions
  end

  monadic_operation! def synchronize_access_info
    call_operation("users.synchronize_access_info", self)
  end

  def testing? = /@example\./.match?(email) || metadata["testing"]

  def to_whoami
    {
      anonymous: false,
      name:
    }
  end

  # @see Users::EmailActions::UpdatePassword
  # @return [Dry::Monads::Success(void)]
  # @return [Dry::Monads::Failure(:request_failed, String)]
  monadic_matcher! def update_password_via_email(**options)
    call_operation("users.email_actions.update_password", self, **options)
  end

  # @!attribute [r] upload_token
  # @return [String]
  def upload_token
    call_operation("uploads.encode_token", self).value_or(nil)
  end

  # @see UserAccessInfo
  # @return [Users::AccessInfo]
  def wrapped_access_info = Users::AccessInfo.wrap(self)

  class << self
    # @param [String] input
    # @return [ActiveRecord::Relation]
    def apply_prefix(input)
      needle = MeruAPI::Container["searching.prefix_sanitize"].(input)

      return all if needle.blank?

      where_begins_like(
        search_given_name: needle,
        search_family_name: needle,
        _or: true,
        _case_sensitive: true
      )
    end

    # Scope users that have *all* allowed actions matching the provided input.
    #
    # @param [<String>] actions
    # @return [ActiveRecord::Relation<User>]
    def with_all_allowed_actions(*actions)
      actions.flatten.reduce(all) do |scope, action|
        scope.with_allowed_actions(action)
      end
    end

    # Scope users that have *any* allowed actions matching the provided input.
    #
    # @param [<String>] actions
    # @return [ActiveRecord::Relation<User>]
    def with_allowed_actions(*actions)
      actions.flatten!

      where(arel_ltree_matches_one_or_any(arel_table[:allowed_actions], actions))
    end

    # Check if the user has a string "realm" role from Keycloak.
    #
    # @api private
    # @return [Arel::Nodes::Equality]
    def arel_has_realm_role(name)
      arel_quote(name).eq(arel_named_fn("ANY", arel_table[:roles]))
    end
  end
end
