# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::Process
    class Processor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :layout_instance, ::Layouts::Types::LayoutInstance
      end

      standard_execution!

      # @return [Dry::Monads::Success(LayoutInstance)]
      def call
        run_callbacks :execute do
          yield upsert_template_digests!

          yield post_process!

          yield upsert_layout_digest!
        end

        Success layout_instance
      end

      wrapped_hook! def upsert_template_digests
        yield layout_instance.upsert_template_instance_digests

        super
      end

      wrapped_hook! def post_process
        yield layout_instance.post_process

        super
      end

      wrapped_hook! def upsert_layout_digest
        yield layout_instance.upsert_layout_instance_digest

        super
      end
    end
  end
end
