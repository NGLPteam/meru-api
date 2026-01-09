# frozen_string_literal: true

module Templates
  class Renderer < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :template_definition, Templates::Types::TemplateDefinition

      param :layout_instance, Templates::Types::LayoutInstance

      option :generation, Templates::Types::Generation
    end

    standard_execution!

    # @return [Template]
    attr_reader :template

    # @return [TemplateInstance]
    attr_reader :template_instance

    delegate :entity, to: :layout_instance
    delegate :template_kind, :position, to: :template_definition

    def call
      run_callbacks :execute do
        yield prepare!

        yield persist_instance!

        yield render!

        yield process!
      end

      Success template_instance
    end

    wrapped_hook! def prepare
      @template = Template.find template_kind

      @template_instance = template.instance_klass.where(template_definition:, layout_instance:, position:).first_or_initialize

      super
    end

    wrapped_hook! def persist_instance
      template_instance.entity = entity

      template_instance.generation = generation

      template_instance.save!

      super
    end

    wrapped_hook! def render
      template_instance.slots = yield template_definition.render_slots(entity:)

      template_instance.save!

      super
    end

    around_render :track_render!

    # @see Templates::Instances::Processor
    wrapped_hook! def process
      yield template_instance.process

      super
    end

    private

    # @return [void]
    def track_render!
      template_instance.track_render!(generation:) do
        yield
      end
    end
  end
end
