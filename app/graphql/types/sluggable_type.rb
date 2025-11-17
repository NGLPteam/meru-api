# frozen_string_literal: true

module Types
  module SluggableType
    include BaseInterface

    description "Objects have a serialized slug for looking them up in the system and generating links without UUIDs"

    field :slug, Types::SlugType, null: false

    def slug
      object.id
    end
  end
end
