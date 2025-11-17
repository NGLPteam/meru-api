# frozen_string_literal: true

module Types
  module EntityBaseType
    include Types::BaseInterface

    description <<~TEXT
    A base interface for entities that contains on-record details,
    but no ability to traverse the hierarchy.
    TEXT

    implements ::Types::SluggableType

    field :title, String, null: false do
      description <<~TEXT
      A human-readable title for the entity.
      TEXT
    end

    field :subtitle, String, null: true do
      description <<~TEXT
      A human-readable subtitle for the entity.
      TEXT
    end

    field :summary, String, null: true do
      description <<~TEXT
      A description of the contents of the entity.
      TEXT
    end
  end
end
