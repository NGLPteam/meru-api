# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::CachedEntityList
    # @see Templates::CachedEntityListItem
    # @see Templates::EntityList
    # @see Templates::Instances::CacheEntityList
    class EntityListCacher < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Templates::Types::TemplateInstance
      end

      standard_execution!

      delegate :id, to: :template_instance, prefix: true

      delegate :entity_id, :entity_type, :list_item_template?, to: :template_instance

      # @return [String]
      attr_reader :advisory_lock_key

      # @return [Templates::CachedEntityList]
      attr_reader :cached_entity_list

      # @return [Templates::EntityList]
      attr_reader :entity_list

      # @return [Boolean]
      attr_reader :hidden_by_entity_list

      # @return [String]
      attr_reader :template_instance_type

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :execute do
          yield prepare!

          yield cache_entity_list!

          yield update_template!
        end

        Success()
      end

      wrapped_hook! def prepare
        @advisory_lock_key = "templates/instances/entity_list_caching/#{template_instance.id}"

        @entity_list = template_instance.entity_list

        @hidden_by_entity_list = !list_item_template? && entity_list.empty?

        @template_instance_type = template_instance.class.name

        super
      end

      wrapped_hook! def cache_entity_list
        yield build_list!

        yield store_items!

        yield prune_items!

        super
      end

      wrapped_hook! def update_template
        template_instance.update_columns(hidden_by_entity_list:)

        super
      end

      wrapped_hook! def build_list
        tuple = {
          template_instance_type:,
          template_instance_id:,
          entity_type:,
          entity_id:,
          **entity_list.to_tuple,
        }

        result = Templates::CachedEntityList.upsert(tuple, unique_by: %i[template_instance_type template_instance_id], returning: :id)

        id = result.pick("id")

        @cached_entity_list = Templates::CachedEntityList.find(id)

        super
      end

      wrapped_hook! def store_items
        # :nocov:
        return super if entity_list.empty?
        # :nocov:

        base_tuple = {
          cached_entity_list_id: cached_entity_list.id,
        }

        tuples = entity_list.valid_entities.map.with_index do |entity, index|
          position = index + 1

          base_tuple.merge(
            list_item_layout_instance_id: entity.list_item_layout_instance.id,
            schema_version_id: entity.schema_version.id,
            entity_type: entity.class.name,
            entity_id: entity.id,
            position:,
          )
        end

        Templates::CachedEntityListItem.upsert_all(tuples, unique_by: %i[cached_entity_list_id position], returning: nil)

        Success()
      end

      wrapped_hook! def prune_items
        cached_entity_list.prune_items!

        super
      end
    end
  end
end
