# frozen_string_literal: true

module Entities
  # Render all layouts for an {HierarchicalEntity entity}.
  class LayoutsRenderer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, Entities::Types::Entity

      option :generation, Rendering::Types::Generation, default: proc { SecureRandom.uuid }
    end

    standard_execution!

    around_execute :acquire_render_lock!

    def call
      run_callbacks :execute do
        yield derive_layout_definitions!

        yield render_each!

        yield prune_invalidations!
      end

      entity.asynchronously_revalidate_frontend_cache!

      Success entity
    end

    wrapped_hook! def derive_layout_definitions
      yield entity.derive_layout_definitions

      entity.entity_derived_layout_definitions.reload

      super
    end

    wrapped_hook! def render_each
      entity.update_columns(generation:)

      Layout.each do |layout|
        yield entity.render_layout(layout.kind, generation:)
      end

      super
    end

    around_render_each :track_render!

    wrapped_hook! def prune_invalidations
      LayoutInvalidation.where(entity:).stale_before(entity.last_rendered_at).delete_all

      super
    end

    private

    # @return [void]
    def acquire_render_lock!
      entity.class.transaction do
        entity.class.with_advisory_lock!(entity.render_lock_key, disable_query_cache: true, timeout_seconds: 30, transaction: true) do
          yield
        end
      end
    end

    # @return [void]
    def track_render!
      entity.track_render!(generation:) do
        yield
      end
    end
  end
end
