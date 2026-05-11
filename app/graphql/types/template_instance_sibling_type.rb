# frozen_string_literal: true

module Types
  # @see TemplateInstanceSibling
  class TemplateInstanceSiblingType < Types::BaseModel
    description <<~TEXT
    A brief detail about a template instance's siblings, to help with finessing certain style concerns.

    For `PREV` siblings, the positions are returned in descending order. If a template is at position
    3 of 5, then these will be returned at position 2 and 1 in that order.

    For `NEXT` siblings, the positions are returned in ascending order. If a template is at position
    3 of 5, then these will be returned at position 4 and 5 in that order.
    TEXT

    field :dark, Boolean, null: false do
      description <<~TEXT
      Whether the sibling has a `DARK` background.
      TEXT
    end

    field :hidden, Boolean, null: false do
      description <<~TEXT
      Whether this sibling is hidden for whatever reason (empty slots, empty entity list, etc).
      TEXT
    end

    field :kind, Types::SiblingKindType, null: false do
      description <<~TEXT
      Whether this is `NEXT` or `PREV`. No functional difference, just illustrative.
      TEXT
    end

    field :layout_kind, Types::LayoutKindType, null: false do
      description <<~TEXT
      The layout this sibling is in. As of now, this should always be `MAIN`,
      since only `MAIN` layout templates can be stacked.
      TEXT
    end

    field :position, Int, null: false do
      description <<~TEXT
      The position of this sibling within the layout instance.
      TEXT
    end

    field :template_kind, Types::TemplateKindType, null: false do
      description <<~TEXT
      The template this sibling is. As of now, this should always be templates within the `MAIN` layout category,
      since only `MAIN` layout templates can be stacked.
      TEXT
    end

    field :width, Types::TemplateWidthType, null: true do
      description <<~TEXT
      The width of the sibling (if available).
      TEXT
    end
  end
end
