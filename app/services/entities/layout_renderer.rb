# frozen_string_literal: true

module Entities
  # Render a _specific_ layout for an {HierarchicalEntity entity}.
  class LayoutRenderer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :entity, Layouts::Types::Entity

      option :layout_kind, Layouts::Types::Kind
    end

    standard_execution!

    delegate :schema_version, to: :entity

    # @return [LayoutDefinition]
    attr_reader :layout_definition

    # @return [Dry::Monads::Success(HierarchicalEntity)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield render_layout!
      end

      Success entity
    end

    wrapped_hook! def prepare
      @layout_definition = find_layout_definition

      super
    end

    wrapped_hook! def render_layout
      yield layout_definition.render(entity)

      Success()
    end

    private

    # @return [LayoutDefinition]
    def find_layout_definition
      schema_version.root_layout_for layout_kind
    end
  end
end
