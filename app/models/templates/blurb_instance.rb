# frozen_string_literal: true

module Templates
  # @see Layouts::MainInstance
  # @see Templates::BlurbDefinition
  # @see Templates::SlotMappings::BlurbInstanceSlots
  # @see Types::Templates::BlurbTemplateInstanceType
  class BlurbInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include TimestampScopes

    layout_kind! :main
    template_kind! :blurb

    attribute :slots, ::Templates::SlotMappings::BlurbInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::BlurbTemplateInstanceType"

    belongs_to :layout_instance,
      class_name: "Layouts::MainInstance",
      inverse_of: :blurb_template_instances

    belongs_to :template_definition,
      class_name: "Templates::BlurbDefinition",
      inverse_of: :template_instances

    belongs_to :entity, polymorphic: true
  end
end
