# frozen_string_literal: true

module Layouts
  # @see Layouts::ListItemInstance
  # @see Types::Layouts::ListItemLayoutDefinitionType
  # @see Templates::ListItemDefinition
  class ListItemDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutDefinition
    include TimestampScopes

    layout_kind! :list_item
    template_kinds! ["list_item"].freeze

    graphql_node_type_name "::Types::Layouts::ListItemLayoutDefinitionType"

    belongs_to :schema_version, inverse_of: :list_item_layout_definitions
    belongs_to :entity, polymorphic: true, optional: true

    has_many :layout_instances,
      -> { for_preloading },
      class_name: "Layouts::ListItemInstance",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :list_item_template_definitions,
      -> { for_preloading },
      class_name: "Templates::ListItemDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_one :template_definition,
      -> { for_preloading },
      class_name: "Templates::ListItemDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id
  end
end
