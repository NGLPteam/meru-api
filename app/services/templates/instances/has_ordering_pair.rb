# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::OrderingPair
    # @see Templates::Instances::FetchOrderingPair
    # @see Templates::Instances::OrderingPairFetcher
    # @see Templates::Definitions::HasOrderingPair
    # @see Types::TemplateOrderingPairType
    # @see Types::TemplateHasOrderingPairType
    module HasOrderingPair
      extend ActiveSupport::Concern
      extend DefinesMonadicOperation

      include Templates::Instances::HasSelectionSource

      included do
        belongs_to :ordering,
          inverse_of: :ordering_template_instances,
          optional: true

        belongs_to :ordering_entry,
          inverse_of: :ordering_template_instances,
          primary_key: %i[ordering_id id],
          foreign_key: %i[ordering_id ordering_entry_id],
          optional: true

        has_one :prev_sibling, -> { includes(:entity) }, through: :ordering_entry
        has_one :next_sibling, -> { includes(:entity) }, through: :ordering_entry

        delegate :entity, to: :prev_sibling, prefix: :prev
        delegate :entity, to: :next_sibling, prefix: :next

        after_save :fetch_ordering_entry!

        after_render :fetch_ordering_entry!
      end

      # @return [Templates::OrderingPair]
      def ordering_pair
        @ordering_pair ||= Templates::OrderingPair.new(self)
      end

      # @see Templates::Instances::FetchOrderingEntry
      # @see Templates::Instances::OrderingEntryFetcher
      # @return [Dry::Monads::Success(void)]
      monadic_operation! def fetch_ordering_entry
        call_operation("templates.instances.fetch_ordering_entry", self)
      end

      # @see Templates::Definitions::ResolveSelectionSource
      # @see Templates::Definitions::SelectionSourceResolver
      # @return [Dry::Monads::Success(HierarchicalEntity)]
      # @return [Dry::Monads::Failure(:no_selection_source)]
      monadic_operation! def resolve_ordering_source
        template_definition.resolve_ordering_source_for(entity)
      end
    end
  end
end
