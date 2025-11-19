# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::Reprocess
    class Reprocessor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Templates::Types::TemplateInstance

        option :update_digest, Templates::Types::Bool, default: proc { false }
      end

      standard_execution!

      # @return [Dry::Monads::Success(TemplateInstance)]
      def call
        run_callbacks :execute do
          yield process!

          yield maybe_update_digest!
        end

        Success template_instance
      end

      wrapped_hook! def process
        yield template_instance.process

        super
      end

      wrapped_hook! def maybe_update_digest
        # :nocov:
        return super unless update_digest

        yield template_instance.upsert_instance_digests

        super
        # :nocov:
      end
    end
  end
end
