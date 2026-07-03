# frozen_string_literal: true

module Types
  # @see ReferencesEntityVisibility
  module ReferencesEntityVisibilityType
    include Types::BaseInterface

    description <<~TEXT
    An entity which can be limited in its visibility, based on some configured attributes.
    TEXT

    field :visibility, Types::EntityVisibilityType, null: false do
      description <<~TEXT
      If an entity is available in the frontend.
      TEXT
    end

    field :hidden_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      If present, this is the timestamp the entity was hidden at.
      TEXT
    end

    field :visible_after_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      If present, this is the timestamp an entity is visible after.
      TEXT
    end

    field :visible_until_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      If present, this is the timestamp an entity is visible until.
      TEXT
    end

    field :hidden, Boolean, null: false, method: :visibility_hidden? do
      description <<~TEXT
      Whether the entity's visibility is set to `HIDDEN`.
      TEXT
    end

    field :visible, Boolean, null: false, method: :visibility_visible? do
      description <<~TEXT
      Whether the entity's visibility is set to `VISIBLE`.
      TEXT
    end

    field :currently_hidden, Boolean, null: false, method: :currently_hidden? do
      description <<~TEXT
      Whether the entity is _currently_ hidden, based on the server's time zone.
      TEXT
    end

    field :currently_visible, Boolean, null: false, method: :currently_visible? do
      description <<~TEXT
      Whether the entity is _currently_ visible, based on the server's time zone.
      TEXT
    end

    field :hidden_as_of, Boolean, null: false do
      description <<~TEXT
      Specify a time to check to see if the entity will be hidden.
      TEXT

      argument :time, GraphQL::Types::ISO8601DateTime, required: false do
        description <<~TEXT
        If no value is provided, it will default to the current time.
        TEXT
      end
    end

    field :visible_as_of, Boolean, null: false do
      description <<~TEXT
      Specify a time to check to see if the entity will be visible.
      TEXT

      argument :time, GraphQL::Types::ISO8601DateTime, required: false do
        description <<~TEXT
        If no value is provided, it will default to the current time.
        TEXT
      end
    end

    def hidden_as_of(time: nil)
      object.hidden_as_of?(time.presence || Time.current)
    end

    def visible_as_of(time: nil)
      object.visible_as_of?(time.presence || Time.current)
    end
  end
end
