# frozen_string_literal: true

module Templates
  # @see Layouts::MetadataInstance
  # @see Templates::MetadataDefinition
  # @see Templates::SlotMappings::MetadataInstanceSlots
  # @see Types::Templates::MetadataTemplateInstanceType
  class MetadataInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include TimestampScopes

    layout_kind! :metadata
    template_kind! :metadata

    attribute :slots, ::Templates::SlotMappings::MetadataInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::MetadataTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::MetadataInstance",
      inverse_of: :metadata_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::MetadataDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
