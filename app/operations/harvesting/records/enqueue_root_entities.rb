# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::RootEntitiesEnqueuer
    class EnqueueRootEntities < Support::SimpleServiceOperation
      service_klass Harvesting::Records::RootEntitiesEnqueuer
    end
  end
end
