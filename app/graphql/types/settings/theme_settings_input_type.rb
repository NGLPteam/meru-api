# frozen_string_literal: true

module Types
  module Settings
    # @see ::Settings::Theme
    class ThemeSettingsInputType < Types::HashInputObject
      description <<~TEXT
      Configuration settings for the theme of the Meru frontend.
      TEXT

      argument :color, String, required: true do
        description <<~TEXT
        The color of the theme, being one of `["cream", "blue", "gray"]`.
        TEXT
      end

      argument :font, String, required: true do
        description <<~TEXT
        The font of the theme, being one of `["style1", "style2", "style3"]`.
        TEXT
      end
    end
  end
end
