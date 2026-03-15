# frozen_string_literal: true

module Templates
  # @see Layouts::MainDefinition
  # @see Templates::BlurbInstance
  # @see Templates::Config::Template::Blurb
  # @see Templates::SlotMappings::BlurbDefinitionSlots
  # @see Types::Templates::BlurbTemplateDefinitionType
  class BlurbDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :main
    template_kind! :blurb

    graphql_node_type_name "::Types::Templates::BlurbTemplateDefinitionType"

    pg_enum! :background, as: :blurb_background, allow_blank: false, suffix: :background, default: "none"

    pg_enum! :width, as: :template_width, allow_blank: false, suffix: :width, default: "full"

    attribute :slots, ::Templates::SlotMappings::BlurbDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MainDefinition",
      inverse_of: :blurb_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::BlurbInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
