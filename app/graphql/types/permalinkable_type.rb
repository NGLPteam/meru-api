# frozen_string_literal: true

module Types
  # @see Permalink
  # @see Permalinkable
  # @see Types::PermalinkType
  module PermalinkableType
    include Types::BaseInterface

    description <<~TEXT
    An interface for models which can have permalinks.
    TEXT

    field :permalinks, [::Types::PermalinkType], null: false do
      description <<~TEXT
      All permalinks associated with this resource.
      TEXT
    end

    field :canonical_permalink, ::Types::PermalinkType, null: true do
      description <<~TEXT
      The canonical permalink for this resource, if one is set.
      TEXT
    end

    load_association! :permalinks

    load_association! :canonical_permalink
  end
end
