# frozen_string_literal: true

# Because of harvesting, we don't actually enforce a unique DOI at the database level, only
# for creating and updating through the API. Duplicate records _shouldn't_ enter the system
# through harvesting, but it's possible.
module HasDOI
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  included do
    scope :by_doi, ->(doi) { where(doi:) }

    scope :sans_valid_doi, -> { where(has_doi: false) }
    scope :with_valid_doi, -> { where(has_doi: true) }

    scope :with_weird_doi, -> { where(has_doi: false).where.not(raw_doi: nil) }

    attribute :doi_data, Entities::DOIData.to_type, default: Dry::Core::Constants::EMPTY_HASH

    strip_attributes only: %i[raw_doi]

    before_validation :extract_doi_data!
  end

  delegate :link, to: :doi_reference, prefix: :doi, allow_nil: true
  delegate :ok?, :url, to: :doi_data, prefix: :doi, allow_nil: true

  # @!attribute [rw] doi
  # At the database level, this is now a virtual column extracted from {#doi_data}.
  #
  # At the instance level, we delegate to {Entities::DOIData#doi}
  #
  # To keep the existing interface, we remap `doi=` to set {#raw_doi}
  # instead, so that the value can be sanitized and extracted.
  #
  # @return [String, nil]
  def doi
    raw_doi_changed? ? raw_doi : doi_data.doi
  end

  def doi=(new_value)
    self.raw_doi = new_value
  end

  # @return [Entities::DOIReference, nil]
  def doi_reference
    extract_doi.value_or(nil)
  end

  # @see Entities::ExtractDOI
  # @return [Dry::Monads::Success(Entities::DOIReference)]
  monadic_operation! def extract_doi
    call_operation("entities.extract_doi", self)
  end

  # @!attribute [r] has_weird_doi
  # @return [Boolean]
  def has_weird_doi
    raw_doi? && !has_doi?
  end

  alias has_weird_doi? has_weird_doi

  private

  # @return [void]
  def extract_doi_data!
    self.doi_data = extract_doi.fmap(&:to_doi_data).value_or(Entities::DOIData.new)
    self.has_doi = doi_ok?
  end

  # @return [void]
  def maybe_migrate_doi_data!
    # simplecov:disable
    return if new_record? || doi_data?

    extract_doi_data!

    update_columns(doi_data:, has_doi:)
    # simplecov:enable
  end

  module ClassMethods
    def has_existing_doi?(raw_doi, except: nil)
      return false if raw_doi.blank?

      relation = where(raw_doi:)

      relation = relation.where.not(id: except.id) if except.present? && except.persisted?

      relation.exists?
    end
  end
end
