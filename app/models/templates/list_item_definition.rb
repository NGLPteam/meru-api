# frozen_string_literal: true

module Templates
  # @see Layouts::ListItemDefinition
  # @see Templates::ListItemInstance
  # @see Templates::Config::Template::ListItem
  # @see Templates::SlotMappings::ListItemDefinitionSlots
  # @see Types::Templates::ListItemTemplateDefinitionType
  class ListItemDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include Templates::Definitions::HasEntityList
    include Templates::Definitions::HasSeeAllOrdering
    include TimestampScopes

    layout_kind! :list_item
    template_kind! :list_item

    graphql_node_type_name "::Types::Templates::ListItemTemplateDefinitionType"

    pg_enum! :selection_fallback_mode, as: :list_item_selection_mode, allow_blank: false, suffix: :selection_fallback_mode, default: "manual"

    pg_enum! :selection_mode, as: :list_item_selection_mode, allow_blank: false, suffix: :selection_mode, default: "manual"

    attribute :dynamic_ordering_definition, ::Schemas::Orderings::Definition.to_type

    attribute :slots, ::Templates::SlotMappings::ListItemDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::ListItemDefinition",
      inverse_of: :list_item_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::ListItemInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
