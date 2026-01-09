# frozen_string_literal: true

module Layouts
  # Render an {HierarchicalEntity entity} for a {LayoutDefinition}.
  class Renderer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :layout_definition, Layouts::Types::LayoutDefinition

      param :entity, Layouts::Types::Entity

      option :generation, Rendering::Types::Generation, default: proc { SecureRandom.uuid }
    end

    standard_execution!

    delegate :layout_kind, to: :layout_definition

    # @return [Layout]
    attr_reader :layout

    # @return [LayoutInstance]
    attr_reader :layout_instance

    def call
      run_callbacks :execute do
        yield prepare!

        yield persist_instance!

        yield render_each_template!

        yield prune_removed_templates!

        yield process!
      end

      Success entity
    end

    wrapped_hook! def prepare
      @layout = Layout.find layout_kind

      @layout_instance = layout.instance_klass.fetch_for(entity, layout_definition:)

      super
    end

    wrapped_hook! def persist_instance
      layout_instance.layout_definition = layout_definition
      layout_instance.generation = generation

      layout_instance.save!

      super
    end

    wrapped_hook! def render_each_template
      layout_definition.template_definitions.each do |template_definition|
        yield template_definition.render(layout_instance, generation:)
      end

      layout_instance.clear_template_instances!

      super
    end

    around_render_each_template :track_render!

    wrapped_hook! def prune_removed_templates
      layout_instance.each_template_instance_association do |association|
        association.where.not(generation:).destroy_all
      end

      super
    end

    # @see Layouts::Instances::Processor
    wrapped_hook! def process
      yield layout_instance.process

      super
    end

    private

    # @return [void]
    def track_render!
      layout_instance.track_render!(generation:) do
        yield
      end
    end
  end
end
