# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::NavigationDefinition
    class NavigationTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::NavigationTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::NavigationBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :hide_metadata, Boolean, null: true do
        description <<~TEXT
        If true, the metadata template/tab should be hidden for this schema.
        TEXT
      end
    end
  end
end
