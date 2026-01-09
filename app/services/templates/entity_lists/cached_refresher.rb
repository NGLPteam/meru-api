# frozen_string_literal: true

module Templates
  module EntityLists
    # @see Templates::EntityLists::RefreshCached
    class CachedRefresher < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :cached_entity_list, Templates::Types::CachedEntityList
      end

      delegate :template_instance, to: :cached_entity_list

      standard_execution!

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :execute do
          yield regenerate!
        end

        Success()
      end

      wrapped_hook! def regenerate
        yield template_instance.cache_entity_list

        cached_entity_list.reload

        super
      end
    end
  end
end
