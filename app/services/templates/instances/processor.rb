# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::Process
    class Processor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :template_instance, Templates::Types::TemplateInstance
      end

      standard_execution!

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :execute do
          yield process!
        end

        Success()
      end

      wrapped_hook! def process
        yield template_instance.post_process

        super
      end
    end
  end
end
