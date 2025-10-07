# frozen_string_literal: true

# A root definition for a controlled vocabulary set of terms.
class ControlledVocabulary < ApplicationRecord
  include HasControlledVocabularyProvisions
  include HasEphemeralSystemSlug
  include TimestampScopes

  self.filter_attributes = [/\Aitem_identifiers\z/, /\Aitem_set\z/]

  DEFAULT_NAMESPACE = "meru.host"

  has_many :contribution_role_configurations, inverse_of: :controlled_vocabulary, dependent: :restrict_with_error

  has_many :controlled_vocabulary_items, -> { in_default_order }, inverse_of: :controlled_vocabulary, dependent: :destroy
  has_many :controlled_vocabulary_sources, inverse_of: :controlled_vocabulary, dependent: :nullify

  has_many_readonly :controlled_vocabulary_root_items, -> { in_default_order.roots }, class_name: "ControlledVocabularyItem", inverse_of: :controlled_vocabulary

  scope :in_default_order, -> { order(namespace: :asc, identifier: :asc, version: :asc) }
  scope :in_provision_order, -> { order(updated_at: :desc) }

  validates :namespace, presence: true, format: { with: ControlledVocabularies::Types::NAMESPACE_PATTERN }
  validates :identifier, presence: true, format: { with: ControlledVocabularies::Types::IDENTIFIER_PATTERN }
  validates :provides, presence: true, format: { with: ControlledVocabularies::Types::PROVIDES_PATTERN }
  validates :version, presence: true, uniqueness: { scope: %i[namespace identifier] }
  validates :name, presence: true

  def first_tagged_with(...)
    tagged_with(...).first
  end

  def for_url(url)
    controlled_vocabulary_items.find_by(url:)
  end

  def has_default_namespace?
    namespace == DEFAULT_NAMESPACE
  end

  # @param [String] identifier
  # @return [ControlledVocabulary, nil]
  def item_for(identifier)
    controlled_vocabulary_items.find_by(identifier:)
  end

  alias fetch_item item_for

  # @see ControlledVocabularies::RerankItems
  # @return [Dry::Monads::Success(Integer)]
  monadic_operation! def rerank_items
    call_operation("controlled_vocabularies.rerank_items", controlled_vocabulary: self)
  end

  def tagged_with(...)
    controlled_vocabulary_items.in_default_order.tagged_with(...)
  end

  # @api private
  # @return [void]
  def select_provider!
    # :nocov:

    return unless persisted?

    tuple = {
      provides:,
      controlled_vocabulary_id: id,
    }

    result = ControlledVocabularySource.upsert(tuple, unique_by: :provides)

    ControlledVocabularySource.find result.pick("id")

    # :nocov:
  end

  # @api private
  monadic_operation! def calculate_item_set
    call_operation("controlled_vocabularies.calculate_item_set", self)
  end

  class << self
    # @raise [ActiveRecord::RecordNotFound]
    # @return [ControlledVocabulary]
    def system_default_contribution_roles
      latest_for!("marc_codes")
    end

    # @param [String] identifier
    # @param [String] namespace
    # @return [ControlledVocabulary, nil]
    def latest_for(identifier, namespace: DEFAULT_NAMESPACE)
      where(namespace:, identifier:).order(version: :desc).first
    end

    # @param [String] identifier
    # @param [String] namespace
    # @raise [ActiveRecord::RecordNotFound]
    # @return [ControlledVocabulary]
    def latest_for!(identifier, namespace: DEFAULT_NAMESPACE)
      where(namespace:, identifier:).order(version: :desc).first!
    end
  end
end
