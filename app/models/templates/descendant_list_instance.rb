# frozen_string_literal: true

module Templates
  # @see Layouts::MainInstance
  # @see Templates::DescendantListDefinition
  # @see Templates::SlotMappings::DescendantListInstanceSlots
  # @see Types::Templates::DescendantListTemplateInstanceType
  class DescendantListInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include Templates::Instances::HasEntityList
    include Templates::Instances::HasSeeAllOrdering
    include TimestampScopes

    layout_kind! :main
    template_kind! :descendant_list

    attribute :slots, ::Templates::SlotMappings::DescendantListInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::DescendantListTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::MainInstance",
      inverse_of: :descendant_list_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::DescendantListDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
