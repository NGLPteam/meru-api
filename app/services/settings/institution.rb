# frozen_string_literal: true

module Settings
  # @see GlobalConfiguration
  # @see ::Types::Settings::InstitutionSettingsInputType
  # @see ::Types::Settings::InstitutionSettingsType
  class Institution
    include Support::EnhancedStoreModel

    strip_attributes collapse_spaces: true

    attribute :name, :string, default: ""

    validates :name, enforced_string: true

    # @api private
    # @return [void]
    def reset!
      self.name = ""
    end
  end
end
