# frozen_string_literal: true

module Testing
  module Factories
    module FactoryEnhancement
      def create(...)
        record = super

        TestingAPI::TestContainer["factories.tracker"].store!(record, caller_locations(1, 1).first.to_s)

        return record
      end
    end
  end
end
