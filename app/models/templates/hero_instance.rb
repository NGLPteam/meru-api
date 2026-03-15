# frozen_string_literal: true

module Templates
  # @see Layouts::HeroInstance
  # @see Templates::HeroDefinition
  # @see Templates::SlotMappings::HeroInstanceSlots
  # @see Types::Templates::HeroTemplateInstanceType
  class HeroInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include TimestampScopes

    layout_kind! :hero
    template_kind! :hero

    attribute :slots, ::Templates::SlotMappings::HeroInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::HeroTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::HeroInstance",
      inverse_of: :hero_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::HeroDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
