# frozen_string_literal: true

module Templates
  # @see Layouts::MainInstance
  # @see Templates::LinkListDefinition
  # @see Templates::SlotMappings::LinkListInstanceSlots
  # @see Types::Templates::LinkListTemplateInstanceType
  class LinkListInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include Templates::Instances::HasEntityList
    include Templates::Instances::HasSeeAllOrdering
    include TimestampScopes

    layout_kind! :main
    template_kind! :link_list

    attribute :slots, ::Templates::SlotMappings::LinkListInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::LinkListTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::MainInstance",
      inverse_of: :link_list_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::LinkListDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
