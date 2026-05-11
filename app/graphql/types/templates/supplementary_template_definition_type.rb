# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::SupplementaryDefinition
    class SupplementaryTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::SupplementaryTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::SupplementaryBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end
    end
  end
end
