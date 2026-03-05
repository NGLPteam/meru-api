# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Entities
    class EntitiesSettingsInputType < Types::HashInputObject
      description <<~TEXT
      An object for updating EntitiesSettings.
      TEXT

      argument :suppress_external_links, Boolean, required: false, default_value: false, replace_null_with_default: true do
        description <<~TEXT
        Whether external links should be suppressed in certain schema field types.
        TEXT
      end
    end
  end
end
