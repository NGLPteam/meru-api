# frozen_string_literal: true

module Types
  # @see Announcement
  # @see Mutations::CreateAnnouncement
  # @see Mutations::DestroyAnnouncement
  # @see Mutations::UpdateAnnouncement
  class AnnouncementType < Types::AbstractModel
    description <<~TEXT
    An announcement tied to an entity. These are configured through the backend and can be used
    to provide time-sensensitive information and news about a specific entity in the system.
    TEXT

    field :entity, "Types::EntityType", null: false,
      description: "The entity that owns the announcement"

    field :published_on, GraphQL::Types::ISO8601Date, null: false,
      description: "The date of the announcement."

    field :header, String, null: false,
      description: "A header value for the announcement"

    field :teaser, String, null: false,
      description: "A teaser for the announcement"

    field :body, String, null: false,
      description: "A body for the announcement"
  end
end
