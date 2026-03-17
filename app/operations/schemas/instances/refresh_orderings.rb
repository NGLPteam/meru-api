# frozen_string_literal: true

module Schemas
  module Instances
    # An operation that handles refreshing all {Ordering}s associated with
    # a specific {HierarchicalEntity entity}.
    #
    # The behavior of this operation depends entirely on the
    # {Schemas::Orderings::Current current}
    # {Schemas::Orderings::RefreshStatus refresh status}.
    #
    # * when `"sync"`, it will synchronously refresh **all**
    #   relevant orderings by calling {Schemas::Orderings::Refresh} directly.
    # * when `"async"`, it will mark the orderings {Ordering#invalidate! stale},
    #   to be processed asynchronously by {OrderingInvalidations::ProcessAllJob}.
    # * when `"disabled"`, it will skip refreshing entirely. This should be used
    #   with caution in live environments, as it means that entity trees will get
    #   inaccurate over time, as far as being able to browse them.
    #
    # @see Schemas::Orderings::Refresh
    class RefreshOrderings
      include Dry::Effects.Resolve(:refresh_status)
      include Dry::Monads[:do, :result]

      # @param [HierarchicalEntity] entity
      # @return [Dry::Monads::Success(void)]
      def call(entity)
        status = Schemas::Orderings::Current.refresh_status

        return Success() if status.disabled?

        Ordering.owned_by_or_ordering(entity).find_each do |ordering|
          # Skip refreshing this ordering if it doesn't apply,
          # for instance an article entity asking about its journal's
          # volume ordering.
          next unless ordering.refreshes_for? entity

          if status.async?
            ordering.invalidate!
          else
            yield ordering.refresh
          end
        end

        return Success()
      end
    end
  end
end
