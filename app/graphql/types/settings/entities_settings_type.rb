# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Entities
    class EntitiesSettingsType < Types::BaseObject
      description <<~TEXT
      Settings specific to how entities should behave on this installation.
      TEXT

      field :suppress_external_links, Boolean, null: false do
        description "Whether external links should be suppressed in certain schema field types."
      end
    end
  end
end
