# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::BuildDigestAttributes
    class DigestAttributesBuilder < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Types::TemplateInstance
      end

      standard_execution!

      delegate :entity_id,
        :entity_type,
        :generation,
        :last_rendered_at,
        :layout_instance,
        :layout_kind,
        :position,
        :render_duration,
        :template_definition,
        :template_kind,
        :template_record,
        :post_processed_at,
        :all_slots_empty,
        :allow_hide,
        :hidden,
        to: :template_instance

      delegate :config, :slots, to: :template_instance, prefix: :template

      delegate :layout_definition, to: :layout_instance

      delegate :has_background?, :has_variant?, :has_width?, to: :template_record

      # @return [Hash]
      attr_reader :attributes

      # @return [Dry::Monads::Success({ Symbol => Object })]
      def call
        run_callbacks :execute do
          yield prepare!

          yield extract_associations!

          yield extract_config_and_slots!
        end

        Success attributes.deep_symbolize_keys
      end

      wrapped_hook! def prepare
        @attributes = build_initial_attributes

        super
      end

      wrapped_hook! def extract_associations
        [
          template_instance,
          template_definition,
          layout_instance,
          layout_definition
        ].each do |model|
          attach_association! model
        end

        super
      end

      wrapped_hook! def extract_config_and_slots
        config = template_config.as_json.deep_symbolize_keys.compact

        slots = template_slots.as_json.deep_symbolize_keys.merge(template_kind:).compact

        attributes!(config:, slots:)

        super
      end

      private

      def attach_association!(model)
        prefix = prefix_for_model_association model

        id = model.id
        type = model.model_name.to_s

        id_key = :"#{prefix}_id"
        type_key = :"#{prefix}_type"

        tuple = { id_key => id, type_key => type }

        attributes!(**tuple)
      end

      def build_initial_attributes
        {
          entity_id:,
          entity_type:,
          generation:,
          position:,
          layout_kind:,
          template_kind:,
          width:,
          render_duration:,
          last_rendered_at:,
          post_processed_at:,
          all_slots_empty:,
          allow_hide:,
          hidden:,
        }
      end

      def prefix_for_model_association(model)
        case model
        in ::LayoutDefinition then :layout_definition
        in ::LayoutInstance then :layout_instance
        in ::TemplateDefinition then :template_definition
        in ::TemplateInstance then :template_instance
        else
          # :nocov:
          raise "Unsupported model: #{model}"
          # :nocov:
        end
      end

      # @return [void]
      def attributes!(**pairs)
        attributes.merge!(pairs)
      end

      def width
        template_definition.width if has_width?
      end
    end
  end
end
