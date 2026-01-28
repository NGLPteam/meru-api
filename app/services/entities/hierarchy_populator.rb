# frozen_string_literal: true

module Entities
  # Populate and maintain the {EntityHierarchy} table from descendants.
  #
  # This happens automatically when {Entities::Sync} is called.
  #
  # @see Entities::SyncHierarchies
  class HierarchyPopulator < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :descendant, Entities::Types::Syncable
    end

    # @return [<SyncsEntities>]
    attr_reader :ancestors

    # @return [Hash]
    attr_reader :common_row

    # @return [String]
    attr_reader :descendant_slug

    # @return [Symbol, nil]
    attr_reader :link_operator

    # @return [<Hash>]
    attr_reader :upsertable_rows

    delegate :auth_path, :hierarchical_id, :hierarchical_type,
      :schema_version, :schema_definition,
      :created_at, :updated_at,
      to: :descendant

    delegate :id, to: :schema_version, prefix: true
    delegate :id, to: :schema_definition, prefix: true

    standard_execution!

    def call
      run_callbacks :execute do
        yield prepare!

        yield find_ancestors!

        yield preload!

        yield upsert!

        yield prune!
      end

      Success()
    end

    wrapped_hook! def prepare
      @ancestors = []

      @link_operator = link_operator_for(descendant)

      @descendant_slug = target_slug_for(descendant)

      @common_row = build_common_row

      @upsertable_rows = []

      super
    end

    wrapped_hook! def find_ancestors
      @ancestors = find_ancestors_recursively_for(descendant)

      super
    end

    # @return [Dry::Monads::Result]
    wrapped_hook! def preload
      ::ActiveRecord::Associations::Preloader.new(records: ancestors, associations: %i[schema_version schema_definition]).call

      super
    end

    # @return [Dry::Monads::Result]
    wrapped_hook! def upsert
      @upsertable_rows = build_upsertable_rows

      EntityHierarchy.upsert_all upsertable_rows, unique_by: %i[ancestor_id descendant_id]

      super
    end

    # @return [Dry::Monads::Result]
    wrapped_hook! def prune
      EntityHierarchy.where(descendant:).where.not(ancestor: ancestors).delete_all

      super
    end

    private

    def build_common_row
      {
        descendant_type: descendant.entity_type,
        descendant_id: descendant.id_for_entity,
        hierarchical_type:,
        hierarchical_id:,
        link_operator:,
        auth_path:,
        schema_definition_id:,
        schema_version_id:,
        title: title_for(descendant),
        descendant_scope: descendant.entity_scope,
        descendant_slug:,
        created_at:,
        updated_at:,
      }
    end

    # @return [<Hash>]
    def build_upsertable_rows
      ancestors.map do |ancestor|
        {
          ancestor_type: ancestor.entity_type,
          ancestor_id: ancestor.id_for_entity,
          ancestor_slug: target_slug_for(ancestor),
          ancestor_scope: ancestor.entity_scope,
        }.merge(common_row)
      end
    end

    # @param [SyncsEntities] value
    # @return [<SyncsEntities>]
    def find_ancestors_recursively_for(value)
      set = Set.new

      set.merge(find_ancestors_for(value))

      set << value

      set.to_a
    end

    # @param [SyncsEntities] value
    # @return [<SyncsEntities>]
    def find_ancestors_for(value)
      case value
      when Community
        [value]
      when ChildEntity
        find_ancestors_recursively_for(value.contextual_parent)
      when EntityLink
        find_ancestors_recursively_for(value.source)
      else
        # :nocov:
        raise "Unknown entity type: #{value.class.name}"
        # :nocov:
      end
    end

    def link_operator_for(value)
      case value
      when EntityLink
        value.operator
      end
    end

    def title_for(value)
      case value
      when EntityLink
        value.target.title
      else
        value.title
      end
    end

    def target_slug_for(value)
      case value
      when EntityLink
        value.target.system_slug
      else
        value.system_slug
      end
    end
  end
end
