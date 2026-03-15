# frozen_string_literal: true

module Templates
  # @see Layouts::NavigationDefinition
  # @see Templates::NavigationInstance
  # @see Templates::Config::Template::Navigation
  # @see Templates::SlotMappings::NavigationDefinitionSlots
  # @see Types::Templates::NavigationTemplateDefinitionType
  class NavigationDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :navigation
    template_kind! :navigation

    graphql_node_type_name "::Types::Templates::NavigationTemplateDefinitionType"

    pg_enum! :background, as: :navigation_background, allow_blank: false, suffix: :background, default: "none"

    attribute :slots, ::Templates::SlotMappings::NavigationDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::NavigationDefinition",
      inverse_of: :navigation_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::NavigationInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
