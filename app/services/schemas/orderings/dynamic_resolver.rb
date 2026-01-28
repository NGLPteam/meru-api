# frozen_string_literal: true

module Schemas
  module Orderings
    # Resolve a dynamic {Schemas::Orderings::Definition} at runtime.
    #
    # @see Schemas::Orderings::ResolveDynamic
    class DynamicResolver < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        option :definition, ::Schemas::Types.Instance(::Schemas::Orderings::Definition)

        option :entity, ::Schemas::Types::SchemaInstance

        option :limit, ::Schemas::Types::Integer.optional, optional: true

        option :id, ::Schemas::Types::String, default: proc { SecureRandom.uuid }
      end

      standard_execution!

      # @return [Schemas::Orderings::Dynamic]
      attr_reader :dynamic

      # @return [<HierarchicalEntity>]
      attr_reader :entities

      # @return [ActiveRecord::Relation]
      attr_reader :query

      # @return [Dry::Monads::Success<HierarchicalEntity>]
      def call
        run_callbacks :execute do
          yield prepare!

          yield resolve!
        end

        Success entities
      end

      wrapped_hook! def prepare
        @dynamic = Schemas::Orderings::Dynamic.new(
          definition:,
          entity:,
          id:
        )

        @entities = EMPTY_ARRAY

        super
      end

      wrapped_hook! def resolve
        entries = OrderingEntryCandidate.currently_visible.query_for(dynamic)

        query = OrderingEntryCandidate
          .with(entries:)
          .select(?*).from("entries").reorder(position: :asc).limit(limit)

        @entities = query.map(&:entity)

        super
      end
    end
  end
end
