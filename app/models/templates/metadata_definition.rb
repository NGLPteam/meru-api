# frozen_string_literal: true

module Templates
  # @see Layouts::MetadataDefinition
  # @see Templates::MetadataInstance
  # @see Templates::Config::Template::Metadata
  # @see Templates::SlotMappings::MetadataDefinitionSlots
  # @see Types::Templates::MetadataTemplateDefinitionType
  class MetadataDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :metadata
    template_kind! :metadata

    graphql_node_type_name "::Types::Templates::MetadataTemplateDefinitionType"

    pg_enum! :background, as: :metadata_background, allow_blank: false, suffix: :background, default: "none"

    attribute :slots, ::Templates::SlotMappings::MetadataDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MetadataDefinition",
      inverse_of: :metadata_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::MetadataInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
