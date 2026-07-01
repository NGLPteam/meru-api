# frozen_string_literal: true

module Harvesting
  module Protocols
    module Unknown
      class RecordExtractor < Harvesting::Protocols::RecordExtractor
        def extract(identifier)
          # simplecov:disable
          Failure[:unsupported]
          # simplecov:enable
        end
      end
    end
  end
end
