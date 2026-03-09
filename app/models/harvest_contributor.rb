# frozen_string_literal: true

# A staging ground to a {Contributor} from a {HarvestSource}.
class HarvestContributor < ApplicationRecord
  include GenericAccessible
  include ScopesForIdentifier
  include TimestampScopes

  pg_enum! :kind, as: "contributor_kind"

  scope :with_connected_contributor, -> { where.not(contributor_id: nil) }

  attribute :links, Contributors::Link.to_array_type
  attribute :properties, Contributors::Properties.to_type

  belongs_to :harvest_source, inverse_of: :harvest_contributors
  belongs_to :contributor, optional: true

  has_many :harvest_contributions, inverse_of: :harvest_contributor, dependent: :destroy

  scope :sans_contributions, -> { where.not(id: HarvestContribution.select(:harvest_contributor_id)) }

  before_validation :normalize_tracked_attributes!
  before_validation :normalize_tracked_properties!

  validates :properties, store_model: true

  validates :identifier, :kind, presence: true
  validates :identifier, uniqueness: { scope: :harvest_source_id }

  delegate :display_name, to: :properties

  private

  # @return [void]
  def normalize_tracked_attributes!
    self.tracked_attributes = normalize_tracked(tracked_attributes).without("identifier")
  end

  # @return [void]
  def normalize_tracked_properties!
    self.tracked_properties = normalize_tracked(tracked_properties)
  end

  # @param [<#to_s>] value
  # @return [<String>]
  def normalize_tracked(value)
    Array(value).map(&:to_s).uniq.sort
  end

  class << self
    # @return [ActiveRecord::Relation]
    def harvested_ids
      with_connected_contributor.select(:contributor_id)
    end
  end
end
