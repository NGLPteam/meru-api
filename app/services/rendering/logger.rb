# frozen_string_literal: true

module Rendering
  # @see Rendering::Log
  class Logger < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :renderable, Rendering::Types.Instance(::Renderable)

      option :generation, Rendering::Types::Generation

      option :render_duration, Rendering::Types::Float
    end

    delegate :schema_version, to: :renderable
    delegate :id, to: :schema_version, prefix: true

    standard_execution!

    # @return [Class(RenderLogModel)]
    attr_reader :render_log_model

    # @return [Hash]
    attr_reader :tuple

    # @return [Dry::Monads::Result]
    def call
      run_callbacks :execute do
        yield prepare!

        yield extract_entity!

        yield extract_details!

        yield insert!
      end

      Success()
    end

    wrapped_hook! def prepare
      @render_log_model = renderable.render_log_model

      @tuple = {
        schema_version_id:,
        generation:,
        render_duration:,
      }

      super
    end

    wrapped_hook! def extract_entity
      case renderable
      when ::HierarchicalEntity
        assign_model! renderable
      else
        assign_model! renderable.entity
      end

      super
    end

    wrapped_hook! def extract_details
      case renderable
      when ::HierarchicalEntity
        # purposely left blank
      when ::LayoutInstance
        assign_model! renderable.layout_definition
      when ::TemplateInstance
        assign_model! renderable.layout_definition
        assign_model! renderable.template_definition
      else
        # simplecov:disable
        raise TypeError, "unknown renderable: #{renderable.inspect}"
        # simplecov:enable
      end

      super
    end

    wrapped_hook! def insert
      render_log_model.insert(tuple, returning: nil)

      super
    end

    private

    # @return [void]
    def assign!(**pairs)
      @tuple.merge!(**pairs)
    end

    # @param [ApplicationRecord] record
    def assign_model!(record)
      case record
      when ::HierarchicalEntity
        assign_polymorphic!(:entity, record)
      when ::LayoutDefinition
        assign!(layout_kind: record.layout_kind)
        assign_polymorphic!(:layout_definition, record)
      when ::TemplateDefinition
        assign!(template_kind: record.template_kind)
        assign_polymorphic!(:template_definition, record)
      else
        # simplecov:disable
        raise TypeError, "invalid assignable: #{record.inspect}"
        # simplecov:enable
      end
    end

    # @param [Symbol] prefix
    # @param [ApplicationRecord] record
    # @return [void]
    def assign_polymorphic!(prefix, record)
      tuple[:"#{prefix}_type"] = record.model_name.to_s
      tuple[:"#{prefix}_id"] = record.id
    end
  end
end
