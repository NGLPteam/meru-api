# frozen_string_literal: true

# An arbitrary page of content associated with a specific {HierarchicalEntity}.
class Page < ApplicationRecord
  include EntityChildRecord
  include HasRelatedEntities
  include ImageUploader::Attachment.new(:hero_image)
  include TimestampScopes

  invalidates_related_entities!

  belongs_to :entity, polymorphic: true, inverse_of: :pages

  validates :title, :slug, :body, presence: true

  validates :slug, uniqueness: { scope: %i[entity_type entity_id] }, format: { with: Support::GlobalTypes::SLUG_PATTERN }

  acts_as_list scope: :entity, add_new_at: :bottom

  scope :by_slug, ->(slug) { where(slug:) }

  scope :in_default_order, -> { order(position: :asc) }

  before_validation :normalize_slug!

  # @api private
  # @return [void]
  def normalize_slug!
    return if Support::GlobalTypes::SLUG_PATTERN.match? slug

    self.slug = slug.to_s.underscore.dasherize
  end
end
