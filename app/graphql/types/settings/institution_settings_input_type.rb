# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Institution
    class InstitutionSettingsInputType < Types::HashInputObject
      description <<~TEXT
      An object for updating the site's configuration.
      TEXT

      argument :name, String, required: false do
        description <<~TEXT
        The name of the institution.
        TEXT
      end
    end
  end
end
