# frozen_string_literal: true

class Contributor < ApplicationRecord
  include HasEphemeralSystemSlug
  include HasHarvestModificationStatus
  include ImageUploader::Attachment.new(:image)
  include SchematicReferent
  include ScopesForIdentifier
  include TimestampScopes

  strip_attributes only: %i[email orcid url]

  pg_enum! :kind, as: "contributor_kind"

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

  has_one :contributor_user_link, dependent: :destroy, inverse_of: :contributor

  has_one :user, through: :contributor_user_link

  scope :by_kind, ->(kind) { where(kind:) }
  scope :by_orcid, ->(orcid) { where(orcid:) }
  scope :unharvested, -> { where.not(id: HarvestContributor.harvested_ids) }

  scope :in_default_order, -> { order(sort_name: :asc) }

  validates :identifier, :kind, presence: true
  validates :identifier, uniqueness: true
  validates :orcid, orcid: { allow_blank: true }

  validates :properties, store_model: true

  delegate :display_name, to: :properties

  # @param [Contributable] contributable
  # @return [Dry::Monads::Result]
  def attach!(contributable)
    call_operation("contributors.attach", self, contributable)
  end

  # @api private
  # @return [void]
  def count_collection_contributions!
    call_operation "contributors.count_collections", self
  end

  # @api private
  # @return [void]
  def count_item_contributions!
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
  def recount_contributions!
    call_operation "contributors.recount_contributions", self
  end

  # @return [String]
  def safe_name
    name.presence || "(Unknown #{display_kind})"
  end

  def to_schematic_referent_label
    display_name
  end

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
