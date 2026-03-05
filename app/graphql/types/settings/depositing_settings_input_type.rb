# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Depositing
    # @see Types::Settings::DepositingSettingsType
    class DepositingSettingsInputType < Types::HashInputObject
      description <<~TEXT
      Settings for depositing to this installation.
      TEXT

      argument :agreement, String, required: false, default_value: "", replace_null_with_default: true do
        description <<~TEXT
        The agreement that users must accept before depositing.
        TEXT
      end

      argument :enabled, Boolean, required: false, default_value: false, replace_null_with_default: true do
        description <<~TEXT
        Whether depositing is enabled for this installation.
        TEXT
      end
    end
  end
end
