# frozen_string_literal: true

module Settings
  # @see ::Types::Settings::ThemeSettingsInputType
  # @see ::Types::Settings::ThemeSettingsType
  class Theme
    include StoreModel::Model

    attribute :color, :string, default: "cream"
    attribute :font, :string, default: "style1"

    validates :color, :font, presence: true
    validates :color, inclusion: { in: Settings::Types::COLOR_SCHEMES }
    validates :font, inclusion: { in: Settings::Types::FONT_SCHEMES }
  end
end
