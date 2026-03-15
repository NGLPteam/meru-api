# frozen_string_literal: true

module Templates
  # @see Layouts::SupplementaryDefinition
  # @see Templates::SupplementaryInstance
  # @see Templates::Config::Template::Supplementary
  # @see Templates::SlotMappings::SupplementaryDefinitionSlots
  # @see Types::Templates::SupplementaryTemplateDefinitionType
  class SupplementaryDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :supplementary
    template_kind! :supplementary

    graphql_node_type_name "::Types::Templates::SupplementaryTemplateDefinitionType"

    pg_enum! :background, as: :supplementary_background, allow_blank: false, suffix: :background, default: "none"

    attribute :slots, ::Templates::SlotMappings::SupplementaryDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::SupplementaryDefinition",
      inverse_of: :supplementary_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::SupplementaryInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
