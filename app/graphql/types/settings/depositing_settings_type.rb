# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Depositing
    # @see Types::Settings::DepositingSettingsInputType
    class DepositingSettingsType < Types::BaseObject
      description <<~TEXT
      Settings for depositing to this installation.
      TEXT

      field :agreement, String, null: false do
        description <<~TEXT
        The agreement that users must accept before depositing.
        TEXT
      end

      field :enabled, Boolean, null: false do
        description <<~TEXT
        Whether depositing is enabled for this installation.
        TEXT
      end
    end
  end
end
