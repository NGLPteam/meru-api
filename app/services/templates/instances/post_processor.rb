# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::PostProcess
    class PostProcessor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Templates::Types::TemplateInstance
      end

      delegate :calculate_allow_hide?, :slots, to: :template_instance

      standard_execution!

      CHANGES = %w[
        all_slots_empty
        allow_hide
        hidden
        hidden_by_empty_slots
      ].freeze

      # @return [Boolean]
      attr_reader :all_slots_empty

      # @return [Boolean]
      attr_reader :allow_hide

      # @return [Boolean]
      attr_reader :hidden_by_empty_slots

      # @return [Dry::Monads::Success(TemplateInstance)]
      def call
        run_callbacks :execute do
          yield maybe_cache_entity_list!

          yield prepare!

          yield calculate_hidden!
        end

        Success template_instance
      end

      wrapped_hook! def maybe_cache_entity_list
        return super unless template_instance.kind_of?(Templates::Instances::HasEntityList)

        yield template_instance.cache_entity_list

        super
      end

      wrapped_hook! def prepare
        @all_slots_empty = slots.all_empty?
        @allow_hide = calculate_allow_hide?
        @hidden_by_empty_slots = slots.hides_template?

        super
      end

      wrapped_hook! def calculate_hidden
        changes = {
          all_slots_empty:,
          allow_hide:,
          hidden_by_empty_slots:,
        }.with_indifferent_access

        template_instance.assign_attributes(changes)

        changes[:hidden] = allow_hide && template_instance.calculate_hidden

        changes[:post_processed_at] = Time.current

        template_instance.update_columns(changes)

        super
      end
    end
  end
end
