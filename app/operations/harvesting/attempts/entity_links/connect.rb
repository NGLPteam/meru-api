# frozen_string_literal: true

module Harvesting
  module Attempts
    module EntityLinks
      # @see Harvesting::Attempts::EntityLinks::Connector
      class Connect < Support::SimpleServiceOperation
        service_klass Harvesting::Attempts::EntityLinks::Connector
      end
    end
  end
end
