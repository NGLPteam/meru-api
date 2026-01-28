# frozen_string_literal: true

# A model that stores a representation of itself in the global {Entity} hierarchy.
#
# @see Entities::Sync
module SyncsEntities
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  included do
    has_one :entity, as: :entity, dependent: :destroy

    after_save :sync_entity!
  end

  # @!group Entity Contract

  # @!attribute [r] auth_path
  # The `auth_path` to use for the entity.
  # @see Entities#auth_path
  # @return [String]
  def entity_auth_path
    auth_path
  end

  # @!attribute [r] id_for_entity
  # @see Entities#entity
  # @note This is not named `entity_id` so as not to conflict with the
  #   Rails association generated method from `entity`.
  # @return [String]
  def id_for_entity
    id
  end

  # @!attribute [r] entity_scope
  # @see Entities#scope
  # @return [String]
  def entity_scope
    model_name.collection
  end

  # @!attribute [r] entity_slug
  # @see Entities#system_slug
  # @return [String]
  def entity_slug
    system_slug
  end

  # @!attribute [r] entity_type
  # @see Entities#entity
  # @return [String]
  def entity_type
    model_name.to_s
  end

  # @!attribute [r] hierarchical_id
  # @see Entity#hierarchical
  # @return [String]
  def hierarchical_id
    id
  end

  # @!attribute hierarchical_type
  # @see Entity#hierarchical
  # @return [String]
  def hierarchical_type
    model_name.to_s
  end

  # @!endgroup

  # @api private
  # @see Entities::Sync
  # @return [void]
  monadic_operation! def sync_entity
    call_operation("entities.sync", self)
  end

  # This generates the tuple of attributes to send to {#sync_entity!} besides
  # the attributes defined as part of the {SyncsEntities}' `Entity Contract`.
  #
  # @api private
  # @abstract
  # @return [{ Symbol => Object }]
  def to_entity_tuple
    {
      properties: to_entity_properties
    }
  end

  # @abstract Override this to set up properties stored on an entity.
  # @api private
  # @see Entity#properties
  # @return [Hash]
  def to_entity_properties
    {}
  end
end
