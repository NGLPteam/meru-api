# frozen_string_literal: true

module Templates
  module EntityLists
    # @abstract
    class AbstractResolver < Support::HookBased::Actor
      extend Dry::Initializer

      option :fallback, Templates::Types::Bool, default: proc { false }

      option :source_entity, Templates::Types::Entity.optional, optional: true

      option :selection_limit, ::Templates::Types::LimitWithFallback, default: proc { Templates::Types::LIMIT_DEFAULT }

      option :selection_unbounded, ::Templates::Types::Bool, default: proc { false }

      option :template_kind, ::Templates::Types::TemplateKind

      option :template_definition_id, ::Schemas::Types::String, default: proc { SecureRandom.uuid }

      standard_execution!

      # @return [<HierarchicalEntity>]
      attr_reader :entities

      # @return [Integer, nil]
      attr_reader :limit

      # @return [Dry::Monads::Success(Templates::EntityList)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield resolve!
        end

        entity_list = Templates::EntityList.new(entities:, fallback:)

        Success entity_list
      end

      wrapped_hook! def prepare
        @entities = EMPTY_ARRAY

        @limit = selection_unbounded ? nil : selection_limit

        super
      end

      wrapped_hook! def resolve
        return super if source_entity.blank?

        resolved = Array(resolve_entities.value_or(EMPTY_ARRAY))

        @entities = only_visible(resolved).then { selection_unbounded ? _1 : _1.take(selection_limit) }

        super
      end

      # @abstract
      # @return [Dry::Monads::Success<HierarchicalEntity>]
      do_for! def resolve_entities
        # simplecov:disable
        Success EMPTY_ARRAY
        # simplecov:enable
      end

      private

      # @param [<HierarchicalEntity, nil>] entities
      # @return [<HierarchicalEntity>]
      def only_visible(entities)
        entities.compact.select { _1.currently_visible? }
      end

      class << self
        def inherited(subclass)
          super

          subclass.do_for!(:resolve_entities)
        end
      end
    end
  end
end
