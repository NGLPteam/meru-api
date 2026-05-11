# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::ContributorListDefinition
    class ContributorListTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::ContributorListTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::ContributorListBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :filter, ::Types::ContributorListFilterType, null: true do
        description <<~TEXT
        Filter which contributors may appear based on their contribution role.
        TEXT
      end

      field :limit, Int, null: true do
        description <<~TEXT
        Limit the number of contributors for this template.
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
