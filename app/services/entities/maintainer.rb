# frozen_string_literal: true

module Entities
  # {HierarchicalEntity Hierarchical entities} are very complex models with a lot of associated data
  # that needs to be denormalized and maintained.
  #
  # This serve is run after a hierarchical entity is saved in order to consolidate that maintenance
  # logic in one place, and to provide benchmarking and disabling of certain maintenance tasks when
  # necessary.
  #
  # @see Entities::Maintain
  class Maintainer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, Entities::Types::Entity

      option :maintenance_mode, Types::MaintenanceMode, default: proc { :update }
    end

    # @api private
    # @see #invoked_by_shrine
    # @return [Regexp]
    INVOKED_BY_SHRINE_PATTERN = /Shrine::Plugins::Activerecord::AttacherMethods#activerecord_persist/

    standard_execution!

    # @return [Boolean]
    attr_reader :applied_properties

    alias applied_properties? applied_properties

    # We use this to detect if we're being invoked by Shrine as part of an attachment lifecycle
    # method, so we don't run more expensive maintenance tasks that aren't affected by that.
    # @return [Boolean]
    attr_reader :invoked_by_shrine

    alias invoked_by_shrine? invoked_by_shrine

    def initialize(...)
      super

      # Ideally we'd set a property on entity instead, but that requires monkey patching Shrine.
      @invoked_by_shrine = caller.grep(INVOKED_BY_SHRINE_PATTERN).present?
    end

    # @return [Dry::Monads::Success(void)]
    def call
      return Success() if invoked_by_shrine?

      run_callbacks :execute do
        yield prepare!

        yield sync!

        yield maintain_properties!

        yield run!

        yield maintain_orderings!

        yield indexing!
      end

      Success()
    end

    wrapped_hook! def prepare
      @applied_properties = false

      super
    end

    wrapped_hook! def sync
      yield entity.sync_entity

      super
    end

    wrapped_hook! def maintain_properties
      @applied_properties = entity.apply_pending_properties!

      entity.persist_named_variable_dates! if entity.kind_of?(ChildEntity)

      super
    end

    wrapped_hook! def run
      yield entity.populate_orderings if create?

      entity.track_parent_changes! if update?

      yield entity.maintain_links if update?

      super
    end

    wrapped_hook! def maintain_orderings
      yield entity.refresh_orderings

      super
    end

    wrapped_hook! def indexing
      # We can skip this if we applied properties.
      yield entity.write_schematic_texts unless applied_properties?

      yield entity.extract_composed_text

      # Asynchronously update the EntitySearchDocument table.
      Entities::IndexSearchDocumentsJob.set(wait: 30.seconds).perform_later(entity)

      super
    end

    wrapped_hook! def rendering
      return super if entity.layout_invalidation_disabled?

      entity.invalidate_layouts!

      entity.invalidate_related_layouts!

      super
    end

    private

    def create? = maintenance_mode == :create

    def update? = maintenance_mode == :update
  end
end
