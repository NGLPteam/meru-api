# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::HeroDefinition
    class HeroTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::HeroTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::HeroBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :descendant_search_prompt, String, null: true, deprecation_reason: "This is a slot now." do
        description <<~TEXT
        TEXT
      end

      field :enable_descendant_browsing, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :enable_descendant_search, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :list_contributors, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_basic_view_metrics, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_big_search_prompt, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_breadcrumbs, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_doi, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_hero_image, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_sharing_link, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_split_display, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_thumbnail_image, Boolean, null: true do
        description <<~TEXT
        TEXT
      end
    end
  end
end
