# frozen_string_literal: true

module Types
  class PageType < Types::BaseObject
    description "A page of arbitrary content for an entity"

    implements GraphQL::Types::Relay::Node

    global_id_field :id

    field :entity, "Types::EntityType", null: false

    field :position, Integer, null: true
    field :title, String, null: false
    field :slug, String, null: false
    field :body, String, null: false

    image_attachment_field :hero_image,
      description: "The hero image for a page"

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
