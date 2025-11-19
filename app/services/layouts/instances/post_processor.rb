# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::PostProcess
    class PostProcessor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :layout_instance, ::Layouts::Types::LayoutInstance
      end

      delegate :template_instance_digests, to: :layout_instance

      standard_execution!

      # @return [Dry::Monads::Success(LayoutInstance)]
      def call
        run_callbacks :execute do
          yield derive_layout_stats!
        end

        Success layout_instance
      end

      wrapped_hook! def derive_layout_stats
        stats = template_instance_digests.layout_instance_stats

        stats => { all_hidden:, all_slots_empty: }

        changes = {
          post_processed_at: Time.current,
          all_hidden:,
          all_slots_empty:,
        }.with_indifferent_access

        layout_instance.update_columns(changes)

        super
      end
    end
  end
end
