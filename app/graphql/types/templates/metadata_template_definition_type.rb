# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::MetadataDefinition
    class MetadataTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::MetadataTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::MetadataBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end
    end
  end
end
