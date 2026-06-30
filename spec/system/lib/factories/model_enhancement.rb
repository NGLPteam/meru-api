# frozen_string_literal: true

module Testing
  module Factories
    module ModelEnhancement
      extend ActiveSupport::Concern

      # @return [String, nil]
      def factory_bot_location
        TestingAPI::TestContainer["factories.tracker"].location_for(self)
      end
    end
  end
end
