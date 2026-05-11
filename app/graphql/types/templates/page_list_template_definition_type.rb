# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::PageListDefinition
    class PageListTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::PageListTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::PageListBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
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
