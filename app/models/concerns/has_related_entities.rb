# frozen_string_literal: true

# A concern for models that need to invalidate their related entities when they are updated or destroyed.
#
# It relies on certain conventions where it looks for certain associations to exist on the model
# and will seek out all related entities.
module HasRelatedEntities
  extend ActiveSupport::Concern

  RELATED_ENTITY_ASSOCIATIONS = %i[
    entity
    items
    collections
  ].freeze

  included do
    extend Dry::Core::ClassAttributes

    defines :invalidates_related_entities, type: Support::Types::Bool

    invalidates_related_entities false

    after_commit :invalidate_related_entities!, if: :should_invalidate_related_entities?
  end

  # Asynchronously {#invalidate_related_orderings!}.
  #
  # @return [void]
  def asynchronously_invalidate_related_orderings!
    Schemas::Orderings.with_asynchronous_refresh do
      invalidate_related_orderings!
    end
  end

  def destroyed_by_entity?
    destroyed_by_association&.foreign_key == "entity_id"
  end

  def each_related_entity
    return enum_for(:each_related_entity) unless block_given?

    seen = Set.new

    related_entity_associations.each do |association|
      associated_records = public_send(association)
      associated_records = [associated_records] unless associated_records.respond_to?(:each)

      associated_records.compact.each do |record|
        if seen.add?(record.id)
          yield record
        end
      end
    end
  end

  # @api private
  # @return [void]
  def invalidate_related_entities!
    each_related_entity do |entity|
      entity.invalidate_layouts!
    end
  end

  def invalidates_related_entities? = self.class.invalidates_related_entities

  # Synchronously invalidate all related orderings.
  #
  # @see #asynchronously_invalidate_related_orderings!
  # @return [void]
  def invalidate_related_orderings!
    each_related_entity do |entity|
      entity.refresh_orderings!
    end
  end

  # @!attribute [r] related_entity_associations
  # @return [<Symbol>]
  def related_entity_associations = self.class.related_entity_associations

  def should_invalidate_related_entities?
    invalidates_related_entities? && !destroyed_by_entity?
  end

  module ClassMethods
    # @return [void]
    def invalidates_related_entities!
      invalidates_related_entities true
    end

    # @!attribute [r] related_entity_associations
    # @return [<Symbol>]
    def related_entity_associations
      @related_entity_associations ||= RELATED_ENTITY_ASSOCIATIONS.select do |assoc|
        reflect_on_association(assoc).present?
      end
    end
  end
end
