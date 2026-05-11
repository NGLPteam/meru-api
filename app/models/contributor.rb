# frozen_string_literal: true

class Contributor < ApplicationRecord
  include FullTextSearchable
  include HasEphemeralSystemSlug
  include HasHarvestModificationStatus
  include ImageUploader::Attachment.new(:image)
  include SchematicReferent
  include ScopesForIdentifier
  include TimestampScopes

  strip_attributes only: %i[email orcid url]

  pg_enum! :kind, as: "contributor_kind"
  pg_enum! :merge_source_status, as: "contributor_merge_source_status", default: "unmerged", allow_blank: false
  pg_enum! :merge_target_status, as: "contributor_merge_target_status", default: "inactive", allow_blank: false, prefix: :merge_target

  attribute :links, Contributors::Link.to_array_type
  attribute :properties, Contributors::Properties.to_type

  has_many :harvest_contributors, inverse_of: :contributor, dependent: :nullify

  has_many :collection_attributions, dependent: :delete_all, inverse_of: :contributor
  has_many :collection_contributions, dependent: :destroy, inverse_of: :contributor
  has_many :collections, through: :collection_contributions

  has_many_readonly :contributor_attributions, inverse_of: :contributor

  has_many :item_attributions, dependent: :delete_all, inverse_of: :contributor
  has_many :item_contributions, dependent: :destroy, inverse_of: :contributor
  has_many :items, through: :item_contributions

  belongs_to :merge_target, class_name: "Contributor", inverse_of: :merge_sources, optional: true

  has_many :merge_sources, class_name: "Contributor", foreign_key: :merge_target_id, inverse_of: :merge_target, dependent: :restrict_with_error

  has_one :contributor_user_link, dependent: :destroy, inverse_of: :contributor

  has_one :user, through: :contributor_user_link

  scope :by_kind, ->(kind) { where(kind:) }
  scope :by_orcid, ->(orcid) { where(orcid:) }
  scope :unharvested, -> { where.not(id: HarvestContributor.harvested_ids) }

  scope :claimed, -> { where.associated(:contributor_user_link) }
  scope :unclaimed, -> { where.missing(:contributor_user_link) }

  scope :in_default_order, -> { order(sort_name: :asc) }

  full_text_searchable_with! :name

  before_validation :derive_merge_target_status!

  after_commit :notify_merge_target!

  validates :identifier, :kind, presence: true
  validates :identifier, uniqueness: true
  validates :orcid, orcid: { allow_blank: true }

  validates :properties, store_model: true

  delegate :display_name, to: :properties

  monadic_matcher! def check_merge_to(other_contributor)
    call_operation "contributors.check_merge", self, other_contributor
  end

  def claimed? = contributor_user_link.present?

  monadic_operation! def copy_contributions
    call_operation "contributors.copy_contributions", self
  end

  # @api private
  # @return [void]
  monadic_operation! def count_collection_contributions
    call_operation "contributors.count_collections", self
  end

  # @api private
  # @return [void]
  monadic_operation! def count_item_contributions
    call_operation "contributors.count_items", self
  end

  # @return [String]
  def display_kind
    return "Contributor" unless kind?

    kind.to_s.titleize
  end

  def fetch_property(property_name, from: nil)
    property_source(from)&.public_send(property_name)
  end

  def graphql_node_type
    organization? ? Types::OrganizationContributorType : Types::PersonContributorType
  end

  # @see Contributors::LinkUser
  # @see Contributors::UserLinker
  # @return [Dry::Monads::Success(ContributorUserLink)]
  monadic_operation! def link_user(user, linkage: "primary")
    call_operation("contributors.link_user", self, user, linkage:)
  end

  # @see Contributors::Merge
  # @see Contributors::Merger
  # @return [Dry::Monads::Success(Contributor)]
  monadic_operation! def merge(other_contributor)
    call_operation("contributors.merge", self, other_contributor)
  end

  def mergeable? = unmerged?

  def merge_busy? = merge_source_busy? || merge_target_busy?

  def merge_prevents_destruction? = merge_target_busy? || merge_sources.exists?

  def merge_source_available? = !merge_source_busy?

  def merge_source_busy? = merging? || merged?

  def merge_started? = merge_source_busy?

  # @api private
  # @param [Contributor] other_contributor
  def merge_target?(other_contributor) = merge_target_id.present? && merge_target_id == other_contributor.id

  def merge_target_busy? = merge_target_active?

  def merge_target_available? = merge_source_available?

  # @return [void]
  def merge_target_status_check!
    derive_merge_target_status!

    update_columns(merge_target_status:) if merge_target_status_changed?
  end

  # @see Contributors::MergeTo
  # @see Contributors::MergeStarter
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def merge_to(other_contributor, **options)
    call_operation("contributors.merge_to", self, other_contributor, **options)
  end

  # @param [Contributor] other_contributor
  def merging_to?(other_contributor) = merging? && merge_target?(other_contributor)

  # @param [Contributor] other_contributor
  # @return [Integer] the number of harvest contributors redirected
  def redirect_harvesting_to!(other_contributor)
    HarvestContributor.where(contributor_id: id).update_all(contributor_id: other_contributor.id)
  end

  def property_source(from)
    case from
    when /organization/
      properties&.organization
    when /person/
      properties&.person
    else
      self
    end
  end

  # @api private
  # @return [void]
  monadic_operation! def recount_contributions
    call_operation "contributors.recount_contributions", self
  end

  # @return [String]
  def safe_name
    name.presence || "(Unknown #{display_kind})"
  end

  # @see Contributions::Attacher
  # @return [Contributor]
  def to_attach = merge_target || self

  def to_schematic_referent_label
    display_name
  end

  def unclaimed? = !claimed?

  # @!group Organization Accessors

  def legal_name
    properties&.organization&.legal_name if organization?
  end

  def location
    properties&.organization&.location if organization?
  end

  # @!endgroup

  # @!group Person Accessors

  # @return [String, nil]
  def given_name
    properties&.person&.given_name if person?
  end

  # @return [String, nil]
  def family_name
    properties&.person&.family_name if person?
  end

  # @return [String, nil]
  def title
    properties&.person&.title if person?
  end

  # @return [String, nil]
  def affiliation
    properties&.person&.affiliation if person?
  end

  # @!endgroup

  private

  # @return [void]
  def derive_merge_target_status!
    self.merge_target_status = merge_sources.exists? ? :active : :inactive
  end

  # @return [void]
  def notify_merge_target!
    merge_target&.merge_target_status_check!
  end

  class << self
    # @param [String] input
    # @return [ActiveRecord::Relation]
    def apply_prefix(input)
      needle = MeruAPI::Container["searching.prefix_sanitize"].(input)

      return all if needle.blank?

      where_begins_like(
        search_name: needle,
        _case_sensitive: true
      )
    end

    def by_given_and_family_name(given_name, family_name)
      person.where(arel_json_contains(:properties, person: { given_name:, family_name: }))
    end

    def by_organization_name(name)
      organization.where(arel_json_contains(:properties, organization: { legal_name: name }))
    end

    def has_existing_orcid?(orcid, except: nil)
      return false if orcid.blank?

      relation = by_orcid(orcid)

      relation = relation.where.not(id: except.id) if except.present? && except.persisted?

      relation.exists?
    end
  end
end
