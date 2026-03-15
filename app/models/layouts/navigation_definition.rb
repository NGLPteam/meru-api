# frozen_string_literal: true

module Layouts
  # @see Layouts::NavigationInstance
  # @see Types::Layouts::NavigationLayoutDefinitionType
  # @see Templates::NavigationDefinition
  class NavigationDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutDefinition
    include TimestampScopes

    layout_kind! :navigation
    template_kinds! ["navigation"].freeze

    graphql_node_type_name "::Types::Layouts::NavigationLayoutDefinitionType"

    belongs_to :schema_version, inverse_of: :navigation_layout_definitions
    belongs_to :entity, polymorphic: true, optional: true

    has_many :layout_instances,
      -> { for_preloading },
      class_name: "Layouts::NavigationInstance",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :navigation_template_definitions,
      -> { for_preloading },
      class_name: "Templates::NavigationDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_one :template_definition,
      -> { for_preloading },
      class_name: "Templates::NavigationDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id
  end
end
