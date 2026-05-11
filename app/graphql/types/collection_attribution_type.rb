# frozen_string_literal: true

module Types
  # @see CollectionAttribution
  class CollectionAttributionType < Types::BaseModel
    description <<~TEXT
    Attributions for collections.
    TEXT

    implements Types::AttributionType

    field :contributor, Types::ContributorBaseType, null: false
  end
end
