# frozen_string_literal: true

module Templates
  # @see Layouts::NavigationInstance
  # @see Templates::NavigationDefinition
  # @see Templates::SlotMappings::NavigationInstanceSlots
  # @see Types::Templates::NavigationTemplateInstanceType
  class NavigationInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include TimestampScopes

    layout_kind! :navigation
    template_kind! :navigation

    attribute :slots, ::Templates::SlotMappings::NavigationInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::NavigationTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::NavigationInstance",
      inverse_of: :navigation_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::NavigationDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
