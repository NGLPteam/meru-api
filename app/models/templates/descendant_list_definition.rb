# frozen_string_literal: true

module Templates
  # @see Layouts::MainDefinition
  # @see Templates::DescendantListInstance
  # @see Templates::Config::Template::DescendantList
  # @see Templates::SlotMappings::DescendantListDefinitionSlots
  # @see Types::Templates::DescendantListTemplateDefinitionType
  class DescendantListDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include Templates::Definitions::HasEntityList
    include Templates::Definitions::HasSeeAllOrdering
    include TimestampScopes

    layout_kind! :main
    template_kind! :descendant_list

    graphql_node_type_name "::Types::Templates::DescendantListTemplateDefinitionType"

    pg_enum! :width, as: :template_width, allow_blank: false, suffix: :width, default: "full"

    pg_enum! :variant, as: :descendant_list_variant, allow_blank: false, suffix: :variant

    pg_enum! :selection_mode, as: :descendant_list_selection_mode, allow_blank: false, suffix: :selection_mode, default: "manual"

    pg_enum! :selection_fallback_mode, as: :descendant_list_selection_mode, allow_blank: false, suffix: :selection_fallback_mode, default: "manual"

    pg_enum! :background, as: :descendant_list_background, allow_blank: false, suffix: :background, default: "none"

    pg_enum! :entity_context, as: :list_entity_context, allow_blank: false, suffix: :entity_context, default: "none"

    attribute :dynamic_ordering_definition, ::Schemas::Orderings::Definition.to_type

    attribute :slots, ::Templates::SlotMappings::DescendantListDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MainDefinition",
      inverse_of: :descendant_list_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::DescendantListInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
