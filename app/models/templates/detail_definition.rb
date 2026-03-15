# frozen_string_literal: true

module Templates
  # @see Layouts::MainDefinition
  # @see Templates::DetailInstance
  # @see Templates::Config::Template::Detail
  # @see Templates::SlotMappings::DetailDefinitionSlots
  # @see Types::Templates::DetailTemplateDefinitionType
  class DetailDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :main
    template_kind! :detail

    graphql_node_type_name "::Types::Templates::DetailTemplateDefinitionType"

    pg_enum! :background, as: :detail_background, allow_blank: false, suffix: :background, default: "none"

    pg_enum! :variant, as: :detail_variant, allow_blank: false, suffix: :variant

    pg_enum! :width, as: :template_width, allow_blank: false, suffix: :width, default: "full"

    attribute :slots, ::Templates::SlotMappings::DetailDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MainDefinition",
      inverse_of: :detail_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::DetailInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
