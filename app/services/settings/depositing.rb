# frozen_string_literal: true

module Settings
  # Settings for depositing to this installation.
  # @see GlobalConfiguration
  # @see ::Types::Settings::DepositingSettingsInputType
  # @see ::Types::Settings::DepositingSettingsType
  class Depositing
    include Support::EnhancedStoreModel

    strip_attributes collapse_spaces: true

    attribute :agreement, :string, default: ""

    attribute :enabled, :boolean, default: false

    validates :agreement, enforced_string: true

    # @api private
    # @return [void]
    def reset!
      self.agreement = ""
    end
  end
end
