# frozen_string_literal: true

module Templates
  # @see Layouts::MainInstance
  # @see Templates::DetailDefinition
  # @see Templates::SlotMappings::DetailInstanceSlots
  # @see Types::Templates::DetailTemplateInstanceType
  class DetailInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include Templates::Instances::HasAnnouncements
    include TimestampScopes

    layout_kind! :main
    template_kind! :detail

    attribute :slots, ::Templates::SlotMappings::DetailInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::DetailTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::MainInstance",
      inverse_of: :detail_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::DetailDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
