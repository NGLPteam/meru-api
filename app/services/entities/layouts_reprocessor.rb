# frozen_string_literal: true

module Entities
  # @see Entities::ReprocessLayouts
  class LayoutsReprocessor < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, Entities::Types::Entity
    end

    standard_execution!

    # @return [Dry::Monads::Success(HierarchicalEntity)]
    def call
      run_callbacks :execute do
        yield reprocess_each_layout!
      end

      entity.asynchronously_revalidate_frontend_cache!

      Success entity
    end

    wrapped_hook! def reprocess_each_layout
      Layout.each do |layout|
        yield entity.reprocess_layout(layout.kind)
      end

      super
    end
  end
end
