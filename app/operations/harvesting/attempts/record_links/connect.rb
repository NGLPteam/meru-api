# frozen_string_literal: true

module Harvesting
  module Attempts
    module RecordLinks
      # @see Harvesting::Attempts::RecordLinks::Connector
      class Connect < Support::SimpleServiceOperation
        service_klass Harvesting::Attempts::RecordLinks::Connector
      end
    end
  end
end
