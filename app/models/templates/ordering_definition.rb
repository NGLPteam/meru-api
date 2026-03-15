# frozen_string_literal: true

module Templates
  # @see Layouts::MainDefinition
  # @see Templates::OrderingInstance
  # @see Templates::Config::Template::Ordering
  # @see Templates::SlotMappings::OrderingDefinitionSlots
  # @see Types::Templates::OrderingTemplateDefinitionType
  class OrderingDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include Templates::Definitions::HasOrderingPair
    include TimestampScopes

    layout_kind! :main
    template_kind! :ordering

    graphql_node_type_name "::Types::Templates::OrderingTemplateDefinitionType"

    pg_enum! :background, as: :ordering_background, allow_blank: false, suffix: :background, default: "none"

    pg_enum! :width, as: :template_width, allow_blank: false, suffix: :width, default: "full"

    attribute :slots, ::Templates::SlotMappings::OrderingDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MainDefinition",
      inverse_of: :ordering_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::OrderingInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
