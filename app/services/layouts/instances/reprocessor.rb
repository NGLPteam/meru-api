# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::Reprocess
    class Reprocessor < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :layout_instance, ::Layouts::Types::LayoutInstance
      end

      standard_execution!

      # @return [Dry::Monads::Success(LayoutInstance)]
      def call
        run_callbacks :execute do
          yield process!
        end

        Success layout_instance
      end

      wrapped_hook! def reprocess_templates
        layout_instance.each_template_instance_association do |association|
          association.find_each do |template_instance|
            yield template_instance.reprocess(update_digest: false)
          end
        end

        super
      end

      wrapped_hook! def process
        yield layout_instance.process

        super
      end
    end
  end
end
