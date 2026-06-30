# frozen_string_literal: true

module Testing
  module Factories
    class Tracker
      def initialize
        @models = Hash.new do |h, k|
          h[k] = {}
        end
      end

      # @param [ApplicationRecord] record
      # @return [String, nil]
      def location_for(record)
        @models[record.class.name][record.id]
      end

      # @param [ApplicationRecord] record
      # @return [ApplicationRecord]
      def store!(record, location)
        @models[record.class.name][record.id] = location

        return record
      end
    end
  end
end
