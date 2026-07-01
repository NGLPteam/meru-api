# frozen_string_literal: true

# A model that registers a {ControlledVocabulary} for a certain `provides` value
# system-wide.
class ControlledVocabularySource < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :controlled_vocabulary, optional: true, inverse_of: :controlled_vocabulary_sources

  scope :in_default_order, -> { order(provides: :asc) }

  scope :unsatisfied, -> { where(controlled_vocabulary: nil) }

  validates :provides, presence: true, uniqueness: true, format: { with: ControlledVocabularies::Types::PROVIDES_PATTERN }

  class << self
    def known_provisions
      SchemaVersionProperty.controlled_vocabulary_provisions | ControlledVocabulary.distinct_provisions
    end

    # @return [ControlledVocabulary, nil]
    def providing(provides)
      where(provides:).first&.controlled_vocabulary
    end

    # @return [void]
    def populate!
      provisions = known_provisions

      attributes = provisions.map { |provides| { provides:, } }

      # simplecov:disable
      return 0 if attributes.blank?
      # simplecov:enable

      result = upsert_all(attributes, unique_by: :provides)

      result.length
    end

    # @return [void]
    def prune!
      where.not(provides: known_provisions).delete_all
    end
  end
end
