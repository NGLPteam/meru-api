# frozen_string_literal: true

module Entities
  # @see Entities::CheckLayouts
  class LayoutsChecker < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :original_entity, Entities::Types::Entity
    end

    standard_execution!

    # A freshly-loaded record with nothing else attached to it
    # that we will use to check.
    #
    # @return [HierarchicalEntity]
    attr_reader :entity

    # @return [Boolean]
    attr_reader :rendered

    # @return [Dry::Monads::Success(Entities::LayoutsProxy)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield check!
      end

      Success Entities::LayoutsProxy.new(entity:, rendered:)
    rescue ActiveRecord::RecordNotFound
      Failure[:entity_deleted]
    end

    wrapped_hook! def prepare
      @entity = original_entity.class.find original_entity.id

      @rendered = false

      super
    end

    wrapped_hook! def check
      return super unless entity.stale?

      yield entity.render_layouts

      if entity.stale?
        # Something went wrong with the re-rerendering process.
        # Mark it as invalid again so it can be retried later.
        entity.invalidate_layouts!
      else
        @rendered = true
      end

      super
    end
  end
end
