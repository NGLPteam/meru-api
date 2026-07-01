# frozen_string_literal: true

module StaleEntities
  # @see StaleEntities::Process
  class Processor < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :stale_entity, StaleEntities::Types::StaleEntity
    end

    standard_execution!

    delegate :entity, :entity_id, :entity_type, :stale_at, to: :stale_entity
    delegate :id, to: :stale_entity, prefix: :sequence

    # @return [Symbol]
    attr_reader :status

    # @return [Dry::Monads::Success(void)]
    def call
      run_callbacks :execute do
        yield check!

        yield maybe_prune!
      end

      Success status
    end

    wrapped_hook! def check
      @status = yield check_layouts!

      super
    end

    wrapped_hook! def maybe_prune
      # In the event that an entity was deleted in an unclean fashion,
      # the underlying layout invalidation might not get cleaned up.
      # This makes sure it does.
      LayoutInvalidation.where(entity_id:, entity_type:).stale_before(stale_at).delete_all

      LayoutInvalidation.where(sequence_id:).delete_all

      super
    end

    private

    # @return [Dry::Monads::Result]
    def check_layouts!
      return Success(:deleted) if entity.nil?

      entity.check_layouts do |m|
        m.success do
          Success(:checked)
        end

        m.failure :entity_deleted do
          # Safe to ignore
          Success(:deleted)
        end

        m.failure do |*ex|
          # Treat as ignored for now. Errors should resolve themselves.
          # TODO: Add log here when Rollbar is added.
          # simplecov:disable
          Success([:failed, *ex])
          # simplecov:enable
        end
      end
    end
  end
end
