# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Institution
    class InstitutionSettingsType < Types::BaseObject
      description <<~TEXT
      Configuration settings for the specific institution featured on this installation.
      TEXT

      field :name, String, null: false do
        description <<~TEXT
        The name of the institution.
        TEXT
      end
    end
  end
end
