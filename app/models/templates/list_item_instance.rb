# frozen_string_literal: true

module Templates
  # @see Layouts::ListItemInstance
  # @see Templates::ListItemDefinition
  # @see Templates::SlotMappings::ListItemInstanceSlots
  # @see Types::Templates::ListItemTemplateInstanceType
  class ListItemInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include Templates::Instances::HasEntityList
    include Templates::Instances::HasSeeAllOrdering
    include TimestampScopes

    layout_kind! :list_item
    template_kind! :list_item

    attribute :slots, ::Templates::SlotMappings::ListItemInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::ListItemTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::ListItemInstance",
      inverse_of: :list_item_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::ListItemDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
