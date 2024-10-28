# frozen_string_literal: true

module Templates
  class PageListDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :main
    template_kind! :page_list

    graphql_node_type_name "::Types::Templates::PageListTemplateDefinitionType"
    pg_enum! :background, as: :page_list_background, allow_blank: false, suffix: :background, default: "none"

    attribute :slots, ::Templates::SlotMappings::PageListDefinitionSlots.to_type

    belongs_to :layout_definition,
      class_name: "Layouts::MainDefinition",
      inverse_of: :page_list_template_definitions

    has_many :template_instances,
      class_name: "Templates::PageListInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
