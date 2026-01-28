# frozen_string_literal: true

module Entities
  # Synchronizes a {SyncsEntities model} into an {Entity} representation.
  class Sync
    include Dry::Monads[:do, :result]
    include Entities::Captors::Syncs::Interface
    include MonadicPersistence
    include MeruAPI::Deps[
      calculate_authorizing: "entities.calculate_authorizing",
      index_search_documents: "entities.index_search_documents",
      prefix_sanitize: "searching.prefix_sanitize",
      sync_hierarchies: "entities.sync_hierarchies",
      validate_sync: "entities.validate_sync",
    ]

    # The index used for upserting an {Entity}.
    UNIQUE_INDEX = %i[entity_type entity_id].freeze

    # @param [SyncsEntities] source
    # @return [Dry::Monads::Result]
    def call(source)
      attributes = yield attributes_from source

      yield upsert! attributes

      yield handle_child_entity! source

      yield index_search! source

      yield sync_hierarchies.(source) unless entity_sync_captured?(source)

      yield calculate_authorizing! source

      Success()
    end

    private

    # @param [SyncsEntities] source
    # @return [Dry::Monads::Success(Hash)]
    # @return [Dry::Monads::Failure(Dry::Validation::Result)]
    def attributes_from(source)
      tuple = source.to_entity_tuple.symbolize_keys

      tuple[:auth_path] = source.entity_auth_path
      tuple[:entity_id] = source.id_for_entity
      tuple[:entity_type] = source.entity_type
      tuple[:hierarchical_id] = source.hierarchical_id
      tuple[:hierarchical_type] = source.hierarchical_type
      tuple[:scope] = source.entity_scope
      tuple[:search_title] = prefix_sanitize.(tuple[:title])
      tuple[:system_slug] = source.entity_slug

      validate_sync.call(tuple).to_monad.fmap(&:to_h)
    end

    # @param [{ Symbol => Object }] attributes
    # @return [Dry::Monads::Result]
    def upsert!(attributes)
      monadic_upsert Entity, attributes, unique_by: UNIQUE_INDEX, skip_find: true
    end

    # @param [HierarchicalEntity] entity
    def index_search!(entity)
      index_search_documents.(entity:)
    end

    # @param [ChildEntity] entity
    # @return [Dry::Monads::Success(void)]
    def handle_child_entity!(entity)
      return Success() unless entity.kind_of?(ChildEntity)

      yield maybe_upsert_visibility! entity

      yield entity.calculate_ancestors

      Success()
    end

    # @param [ChildEntity] entity
    # @return [Dry::Monads::Result]
    def maybe_upsert_visibility!(entity)
      tuple = {}

      tuple[:entity_id] = entity.id_for_entity
      tuple[:entity_type] = entity.entity_type

      monadic_upsert EntityVisibility, tuple, unique_by: UNIQUE_INDEX, skip_find: true
    end

    # @param [SyncsEntities] source
    # @return [Dry::Monads::Result]
    def calculate_authorizing!(source)
      calculate_authorizing.call auth_path: source.entity_auth_path
    end
  end
end
