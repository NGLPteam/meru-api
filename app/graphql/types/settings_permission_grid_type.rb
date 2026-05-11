# frozen_string_literal: true

module Types
  class SettingsPermissionGridType < Types::BaseObject
    description <<~TEXT
    Permissions related to managing global configuration settings in Meru.
    TEXT

    implements Types::PermissionGridType

    field :update, Boolean, null: false do
      description <<~TEXT
      Whether the user can update global configuration settings in Meru.
      TEXT
    end
  end
end
