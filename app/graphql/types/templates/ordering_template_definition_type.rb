# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::OrderingDefinition
    class OrderingTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::OrderingTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::OrderingBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :ordering_identifier, Types::SchemaComponentType, null: true do
        description <<~TEXT
        The identifier for the ordering to derive next/prev siblings from.

        Refer to `orderingSource` and `selectionSource` for more details.
        TEXT
      end

      field :ordering_source, ::Types::TemplateSelectionSourceType, null: true do
        description <<~TEXT
        A reference to the entity that contains an ordering identified by `orderingIdentifier`.
        It operates exactly like `selectionSource`. See that property for more documentation.

        **Note**: While `self` is allowed here, it only makes sense if the rendering entity
        is contained in one of its own orderings, which doesn't happen normally. The template
        will still render, but it likely won't find siblings.
        TEXT
      end

      field :ordering_source_ancestor_name, Types::SchemaComponentType, null: true do
        description <<~TEXT
        TEXT
      end

      field :ordering_source_mode, ::Types::SelectionSourceModeType, null: true do
        description <<~TEXT
        TEXT
      end

      field :selection_source, ::Types::TemplateSelectionSourceType, null: true do
        description <<~TEXT
        What entity to use for detecting the positional prev/next siblings.

        By default, it is `self`. However, it can be overridden for creating templates that
        navigate through parent issues, volumes, journals, etc. For instance, an article could
        create an `<ordering />` template that has the following properties set:

        * `selectionSource`: `"ancestors.issue"`
        * `orderingSource`: `"ancestors.journal"`
        * `orderingIdentifier`: `"issues"`

        This would use the _journal's_ `issues` ordering to navigate through the article's
        associated `issues`, and provide a quick way to navigate through varying levels of
        the upper hierarchy from lower points in the tree.
        TEXT
      end

      field :selection_source_ancestor_name, Types::SchemaComponentType, null: true do
        description <<~TEXT
        The derived name of the ancestor used for the `selectionSource`.

        Exposed for introspection only.
        TEXT
      end

      field :selection_source_mode, ::Types::SelectionSourceModeType, null: true do
        description <<~TEXT
        An enum representing what mode `selectionSource` is in. Not directly set,
        it is used internally for lookups.
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
