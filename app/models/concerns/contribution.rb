# frozen_string_literal: true

# A contribution from a {Contributor} to a {Contributable}.
module Contribution
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include HasEphemeralSystemSlug
  include Liquifies
  include TimestampScopes

  included do
    extend Dry::Core::ClassAttributes

    defines :contributable_key, type: Contributions::Types::ContributableKey
    defines :contributables_key, type: Contributions::Types::ContributablesKey
    defines :contributable_foreign_key, type: Contributions::Types::ContributableForeignKey
    defines :contributable_klass_name, type: Contributions::Types::ContributableKlassName

    contributable_key :"#{model_name.singular[/\A(.+)_contribution\z/, 1]}"
    contributables_key contributable_key.to_s.pluralize.to_sym
    contributable_foreign_key :"#{contributable_key}_id"
    contributable_klass_name model_name.to_s[/\A(.+)Contribution\z/, 1]

    belongs_to :role, class_name: "ControlledVocabularyItem", inverse_of: table_name

    attribute :metadata, Contributions::Metadata.to_type, default: proc { {} }

    drop_klass Templates::Drops::ContributionDrop

    delegate :target_association, :target_association_name, :target_klass, to: :class

    delegate :kind, to: :contributor, prefix: true

    scope :authors, -> { where(role_id: ControlledVocabularyItem.tagged_with("author").select(:id)) }

    scope :in_default_contributor_order, -> { joins(:contributor).merge(Contributor.in_default_order) }

    validates :role_id, uniqueness: { scope: %I[contributor_id #{contributable_foreign_key}] }

    before_validation :set_default_role!, on: :create

    after_save :reload_contributor!

    after_destroy :recount_contributor_contributions!

    after_save_commit :manage_attributions!
  end

  # @!attribute [r] contributable
  # @return [Contributable]
  def contributable
    __send__(contributable_key)
  end

  # @!attribute [r] contributable_key
  # @return [Contributions::Types::ContributableKey]
  def contributable_key
    self.class.contributable_key
  end

  # @!attribute [r] contributable_foreign_key
  # @return [Contributions::Types::ContributableForeignKey]
  def contributable_foreign_key
    self.class.contributable_foreign_key
  end

  # @!attribute [r] contributable_klass_name
  # @return [Contributions::Types::ContributionKlassName]
  def contributable_klass_name
    self.class.contributable_klass_name
  end

  # @!attribute [r] contributables_key
  # @return [Contributions::Types::ContributablesKey]
  def contributables_key
    self.class.contributables_key
  end

  def display_name
    overridable_contributor_attribute :display_name
  end

  def affiliation
    overridable_contributor_attribute :affiliation, kind: :person
  end

  def title
    overridable_contributor_attribute :title, kind: :person
  end

  def location
    overridable_contributor_attribute :location, kind: :organization
  end

  # @see Attributions::Collections::Manage
  # @see Attributions::Items::Manage
  # @return [Dry::Monads::Result]
  monadic_operation! def manage_attributions
    options = { contributable_key => __send__(contributable_key) }

    call_operation("attributions.#{contributables_key}.manage", **options)
  end

  private

  def overridable_contributor_attribute(attribute_name, kind: nil)
    self.metadata ||= {}

    metadata.fetch attribute_name do
      contributor.fetch_property(attribute_name, from: kind)
    end
  end

  # @return [void]
  def recount_contributor_contributions!
    return if destroyed_by_association&.foreign_key == "contributor_id"

    case model_name.to_s
    when /\ACollection/
      contributor.count_collection_contributions!
    when /\AItem/
      contributor.count_item_contributions!
    end
  end

  # @return [void]
  def reload_contributor!
    recount_contributor_contributions!

    return unless association(:contributor).loaded?

    contributor.reload
  end

  # @return [void]
  def set_default_role!
    return if role.present?

    contributable = __send__(contributable_key)

    self.role = call_operation("contribution_roles.fetch_default", contributable:).value!
  end

  module ClassMethods
    # @param [Templates::Types::ContributionListFilter] all
    # @param [Templates::Types::LimitWithFallback] limit
    # @return [ActiveRecord::Relation<Contribution>]
    def for_template_list(filter: "all", limit: Templates::Types::LIMIT_DEFAULT)
      filter = Templates::Types::ContributorListFilter[filter]

      limit = Templates::Types::LimitWithFallback[limit]

      base =
        case filter
        in "authors"
          authors
        else
          all
        end

      base.preloaded_for_record_loading.limit(limit).in_default_contributor_order
    end

    def preloaded_for_record_loading
      super.includes(:role, :contributor)
    end

    # @param ["asc", "desc"] direction
    # @return [ActiveRecord::Relation<Contribution>]
    def with_ordered_target_title(direction: "asc")
      lazily_order(:target_title, direction)
    end

    def prepare_order_for_target_title
      joins(target_association_name)
    end

    def target_title_order_column
      target_klass.arel_table[:title]
    end

    # @api private
    # @return [ActiveRecord::Reflection::BelongsToReflection]
    def target_association
      @target_association ||= find_target_association
    end

    # @api private
    # @return [Symbol]
    def target_association_name
      target_association.name
    end

    # @api private
    # @return [Class]
    def target_klass
      target_association.klass
    end

    private

    # @return [ActiveRecord::Reflection::BelongsToReflection]
    def find_target_association
      case model_name.to_s
      when /\ACollection/
        reflect_on_association(:collection)
      when /\AItem/
        reflect_on_association(:item)
      else
        # :nocov:
        raise "Cannot derive target association for #{model_name}"
        # :nocov:
      end
    end
  end
end
