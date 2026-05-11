# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::DescendantListDefinition
    class DescendantListTemplateDefinitionType < ::Types::BaseModel
      implements ::Types::TemplateDefinitionType

      field :slots, ::Types::Templates::DescendantListTemplateDefinitionSlotsType, null: false do
        description <<~TEXT
        Slot definitions for this template.
        TEXT
      end

      field :background, ::Types::DescendantListBackgroundType, null: true do
        description <<~TEXT
        The background gradient to use for this template. Affects presentation.
        TEXT
      end

      field :browse_style, Boolean, null: true do
        description <<~TEXT
        A boolean used to describe list templates that should match browse style as close as possible.
        TEXT
      end

      field :dynamic_ordering_definition, Types::OrderingDefinitionType, null: true do
        description <<~TEXT
        When `selectionMode` is set to `DYNAMIC`, this uses the same basic structure
        as schemas to define a dynamic ordering that is resolved at runtime and based
        on the `selectionSource`.
        TEXT
      end

      field :entity_context, ::Types::ListEntityContextType, null: true do
        description <<~TEXT
        Enumerate how much context to show when listing entities.

        Replaces `showEntityContext`.
        TEXT
      end

      field :manual_list_name, Types::SchemaComponentType, null: true do
        description <<~TEXT
        When `selectionMode` is set to `MANUAL`, the purpose of this property
        is to specify a name under which all the manual selections (per entity)
        will be stored. This allows a layout to have multiple templates of the
        same type using different lists, that will persist across rearrangements
        of the layout _without_ losing connections between entities.
        TEXT
      end

      field :ordering_identifier, Types::SchemaComponentType, null: true do
        description <<~TEXT
        When `selectionMode` is set to `NAMED`, this will look up the named ordering
        on the resolved `selectionSource` and render up to `selectionLimit` entities.
        TEXT
      end

      field :see_all_button_label, String, null: true do
        description <<~TEXT
        TEXT
      end

      field :see_all_ordering_identifier, Types::SchemaComponentType, null: true do
        description <<~TEXT
        If provided, this will expose an ordering on the template instance that can
        be used to generate a link to the ordering in the frontend.
        TEXT
      end

      field :selection_fallback_mode, ::Types::DescendantListSelectionModeType, null: true do
        description <<~TEXT
        The fallback mode to use when rendering a list of entities, when the list from
        `selectionMode` is empty and `useSelectionFallback` has been set to true.
        TEXT
      end

      field :selection_limit, Int, null: true do
        description <<~TEXT
        Regardless of `selectionMode`, this limit will be applied on whatever resulting
        list of entities are produced, so that only up to that amount of entities are
        rendered in the template proper.
        TEXT
      end

      field :selection_mode, ::Types::DescendantListSelectionModeType, null: true do
        description <<~TEXT
        The default mode to use when rendering a list of entities.

        See also `selectionFallbackMode` and `useSelectionFallback`.
        TEXT
      end

      field :selection_property_path, Types::SchemaPropertyPathType, null: true do
        description <<~TEXT
        When `selectionMode` is set to `PROPERTY`, this should be set to the full path
        for a given schema property on the associated `selectionSource`
        TEXT
      end

      field :selection_source, ::Types::TemplateSelectionSourceType, null: true do
        description <<~TEXT
        When selecting entities based on `selectionMode`, this property determines
        which entity (relevant to the rendering entity) should be used for lookups.

        By default, it is `self`, which means the rendering entity itself.

        It can also support things like `ancestor.journal`, `ancestor.issue`, etc.,
        in order to render a list of values in its parent.
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

      field :selection_unbounded, Boolean, null: true do
        description <<~TEXT
        When true, this takes priority over `selectionLimit`. It allows an entire
        matching list of records to be retrieved. It should be used with caution,
        since very large entity trees could cause responses to be slow.
        TEXT
      end

      field :show_contributors, Boolean, null: true do
        description <<~TEXT
        Show contributors when listing entities.
        TEXT
      end

      field :show_entity_context, Boolean, null: true, deprecation_reason: "Use entity_context enum instead" do
        description <<~TEXT
        Show additional context about each entity in the selection.
        TEXT
      end

      field :show_hero_image, Boolean, null: true do
        description <<~TEXT
        TEXT
      end

      field :show_nested_entities, Boolean, null: true do
        description <<~TEXT
        Show nested items from the associated listItemLayouts in order to generate
        a two-tier list.
        TEXT
      end

      field :show_see_all_button, Boolean, null: true, deprecation_reason: "Use seeAllOrdering on the instance instead." do
        description <<~TEXT
        TEXT
      end

      field :title, String, null: true do
        description <<~TEXT
        TEXT
      end

      field :use_selection_fallback, Boolean, null: true do
        description <<~TEXT
        Controls whether or not to use `selectionFallbackMode` if the entity list returned
        via `selectionMode` turns out to be empty at runtime.
        TEXT
      end

      field :variant, ::Types::DescendantListVariantType, null: true do
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
