# frozen_string_literal: true

module Templates
  # @see Layouts::SupplementaryInstance
  # @see Templates::SupplementaryDefinition
  # @see Templates::SlotMappings::SupplementaryInstanceSlots
  # @see Types::Templates::SupplementaryTemplateInstanceType
  class SupplementaryInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include TimestampScopes

    layout_kind! :supplementary
    template_kind! :supplementary

    attribute :slots, ::Templates::SlotMappings::SupplementaryInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::SupplementaryTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::SupplementaryInstance",
      inverse_of: :supplementary_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::SupplementaryDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
