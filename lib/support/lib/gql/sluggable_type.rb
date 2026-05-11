# frozen_string_literal: true

module Support
  module GQL
    # An interface that specifies that a record can be looked up via {Support::GQL::SlugType}.
    module SluggableType
      include Support::GQL::BaseInterface

      description <<~TEXT
      Objects have a serialized slug for looking them up in the system and generating links without UUIDs.
      TEXT

      field :slug, Support::GQL::SlugType, null: false do
        description <<~TEXT
        The encoded slug for this record.
        TEXT
      end

      # @note This value will be parsed by {Support::GQL::SlugType} to encode the primary key.
      # @return [String]
      def slug = object.id
    end
  end
end
