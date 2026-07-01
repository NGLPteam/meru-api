# frozen_string_literal: true

module Seeding
  module Brokers
    # A root-level broker for the system. Instantiated via the brokerage DSL.
    class RootBroker < Broker
      attribute :community, Seeding::Brokers::CommunityBroker
      attribute :collection, Seeding::Brokers::CollectionBroker

      def entity_broker_for(model)
        case model
        when ::Community then community
        when ::Collection then collection
        else
          # simplecov:disable
          raise TypeError, "Cannot retrieve broker for #{model.class.name}"
          # simplecov:enable
        end
      end

      def schema_broker_for(model)
        entity_broker_for(model).schema_broker_for(model.schema_version)
      end

      # @param [ApplicationRecord] model
      def supported?(model)
        case model
        when ::Community then community.supported?(model)
        when ::Collection then collection.supported?(model)
        else
          false
        end
      end
    end
  end
end
