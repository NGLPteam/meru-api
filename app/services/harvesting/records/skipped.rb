# frozen_string_literal: true

module Harvesting
  module Records
    # Stores the reason a record was skipped (if any).
    class Skipped
      include StoreModel::Model
      include ::Support::Typing

      attribute :active, :boolean, default: false
      attribute :reason, :string
      attribute :code, :string
      attribute :at, :datetime
      attribute :metadata, :indifferent_hash

      validates :reason, presence: { if: :active }

      class << self
        # @param [String] reason
        # @param [Time] at
        # @param [{ Symbol => Object }] metadata
        # @return [Harvesting::Records::Skipped]
        def because(reason, at: Time.current, code: nil, **metadata)
          new(active: true, reason:, at:, code:, metadata:)
        end

        # @return [Harvesting::Records::Skipped]
        def blank
          new(active: false)
        end
      end
    end
  end
end
