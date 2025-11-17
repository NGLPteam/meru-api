# frozen_string_literal: true

module Types
  # @see ::HarvestTarget
  module HarvestTargetType
    include Types::BaseInterface

    description <<~TEXT
    An entity that can serve as the target for a `HarvestAttempt`.

    In effect, it is limited to `Community` and `Collection`.
    TEXT

    implements Types::EntityBaseType
    implements ::Types::SluggableType

    field :harvest_target_kind, Types::HarvestTargetKindType, null: false do
      description <<~TEXT
      Whether this is a collection or a community.
      TEXT
    end
  end
end
