# frozen_string_literal: true

module Harvesting
  module Protocols
    module Unknown
      # @api private
      class RecordProcessor < Harvesting::Protocols::RecordProcessor
        # @param [OAI::Record] oai_record
        def deleted?(_)
          # simplecov:disable
          true
          # simplecov:enable
        end

        def skip?(_)
          # simplecov:disable
          true
          # simplecov:enable
        end
      end
    end
  end
end
