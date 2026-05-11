# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::DetailDefinition
    class DetailTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::DetailTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::DetailBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :show_announcements, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_body, Boolean, null: true do
        description <<~TEXT
        Whether to show and use the 'body' slot on a detail view.
        Primarily intended for items with copious text to display.
        TEXT
      end

      field :show_hero_image, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :variant, ::Types::DetailVariantType, null: true do
        description <<~TEXT
        The variant rendering mode to use for this template. Affects presentation.
        TEXT
      end

      field :width, ::Types::TemplateWidthType, null: true do
        description <<~TEXT
        This controls how wide the template should render.

        **Note**: When using `HALF`, you should take care to make sure that there is an adjacent
        template that also uses `HALF`.
        TEXT
      end
    end
  end
end
