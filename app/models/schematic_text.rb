# frozen_string_literal: true

# A schematic reference to a full-text searchable block of text. Ideal for storing the entire
# contents of an article, issue, or any other entity type. It differs from more typical text content
# in that it is intended to be full-text searchable (with stemming, etc)
#
# @see FullText::Types::Reference
# @see Schemas::Properties::Scalar::FullText
# @see Types::Schematic::FullTextPropertyType
class SchematicText < ApplicationRecord
  include SchematicPathValidity

  belongs_to :entity, polymorphic: true

  # rubocop:disable Rails/InverseOf
  belongs_to :composite_entity, class_name: "Entity",
    foreign_key: %i[entity_type entity_id],
    primary_key: %i[entity_type entity_id]
  # rubocop:enable Rails/InverseOf

  has_one :schema_version, through: :composite_entity

  validates :path, presence: true, uniqueness: { scope: :entity }
  validates :dictionary, full_text_dictionary: true

  scope :by_entity, ->(entity) { where(entity: entity) }
  scope :by_path, ->(path) { where(path: path) }

  before_validation :normalize_columns!

  # Turn this model into a reference suitable for use with schema values
  # directly.
  #
  # @see FullText::Types::Reference
  # @return [{ Symbol => String }]
  def to_reference
    FullText::Types::Reference[slice(:content, :kind, :lang)]
  end

  # @api private
  # @return [void]
  def normalize_columns!
    self.dictionary = call_operation("full_text.derive_dictionary", lang)
    self.text_content = call_operation("full_text.extract_text_content", to_reference)
  end

  class << self
    def valid_paths_column
      :text_reference_paths
    end
  end
end
