# frozen_string_literal: true

module Entities
  # Synchronizes a {SyncsEntities model} into an {Entity} representation.
  class Sync
    include Dry::Monads[:do, :result]
    include MeruAPI::Deps[
      calculate_authorizing: "entities.calculate_authorizing",
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

      yield sync_hierarchies.(source)

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
      tuple[:submission_status] = source.entity_submission_status

      validate_sync.call(tuple).to_monad.fmap(&:to_h)
    end

    # @param [{ Symbol => Object }] attributes
    # @return [Dry::Monads::Result]
    def upsert!(attributes)
      Entity.upsert(attributes, unique_by: UNIQUE_INDEX, returning: nil)

      Success()
    end

    # @param [ChildEntity] entity
    # @return [Dry::Monads::Success(void)]
    def handle_child_entity!(entity)
      return Success() unless entity.kind_of?(ChildEntity)

      ensure_visibility! entity

      yield entity.calculate_ancestors

      Success()
    end

    # @param [ChildEntity] entity
    # @return [void]
    def ensure_visibility!(entity)
      visibility = entity.actual_entity_visibility

      return if visibility.persisted?

      visibility.entity_id ||= entity.id

      visibility.save!
    end

    # @param [SyncsEntities] source
    # @return [Dry::Monads::Result]
    def calculate_authorizing!(source) = calculate_authorizing.call(auth_path: source.entity_auth_path)
  end
end
