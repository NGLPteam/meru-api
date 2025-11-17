# frozen_string_literal: true

module Types
  # A utility service for looking up information about the Meru-API ecosystem.
  class SystemInfoType < Types::BaseObject
    description <<~TEXT
    A helper field that can look up various information about the Meru-API Ecosystem.
    TEXT

    field :entity_hierarchy_exists, Boolean, null: false do
      description <<~TEXT
      Check to see if an entity of a given `descendant` type exists with a given `ancestor` type.
      TEXT

      argument :ancestor, Types::SlugType, required: true do
        description "Should be `namespace:identifier`."
      end

      argument :descendant, Types::SlugType, required: true do
        description "Should be `namespace:identifier`."
      end
    end

    # @param [String] ancestor
    # @param [String] descendant
    # @return [Boolean]
    def entity_hierarchy_exists(ancestor:, descendant:)
      Entity.of_type_with_ancestor_of_type?(descendant, ancestor)
    end
  end
end
