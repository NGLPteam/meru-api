# frozen_string_literal: true

# @see Permalinkable
# @see Types::PermalinkType
# @see Types::PermalinkableType
class Permalink < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  URI_FORMAT = /\A[[:alnum:]]+(?:-[[:alnum:]]+)*\z/

  pg_enum! :kind, as: :permalinkable_kind, allow_blank: false, prefix: :to

  belongs_to :permalinkable, polymorphic: true, inverse_of: :permalinks

  scope :canonical, -> { where(canonical: true) }

  scope :in_default_order, -> { order(canonical: :desc, uri: :asc) }

  before_validation :derive_kind!

  before_validation :extract_permalinkable_slug!

  before_validation :enforce_canonicity!, if: :should_enforce_canonicity?

  validates :canonical, uniqueness: { scope: %i[permalinkable_type permalinkable_id] }, if: :canonical?

  validates :uri, presence: true, uniqueness: true, length: { minimum: 3, maximum: 250 }, format: { with: URI_FORMAT }

  def should_enforce_canonicity?
    return false unless canonical?

    canonical_changed? || permalinkable_id_changed?
  end

  private

  # @return [void]
  def derive_kind!
    # :nocov:
    return if permalinkable.blank?
    # :nocov:

    self.kind = determine_kind!
  end

  # @return [String]
  monadic_operation! def determine_kind
    call_operation("permalinks.determine_kind", permalinkable)
  end

  # @return [void]
  def enforce_canonicity!
    return unless canonical?

    # Unset canonical on other permalinks for the same permalinkable
    Permalink.where(permalinkable:).where.not(id:).update_all(canonical: false)
  end

  # @return [void]
  def extract_permalinkable_slug!
    # :nocov:
    return if permalinkable.blank?
    # :nocov:

    self.permalinkable_slug = permalinkable.system_slug
  end
end
