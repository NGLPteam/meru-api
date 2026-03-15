# frozen_string_literal: true

module Templates
  # @see Layouts::HeroDefinition
  # @see Templates::HeroInstance
  # @see Templates::Config::Template::Hero
  # @see Templates::SlotMappings::HeroDefinitionSlots
  # @see Types::Templates::HeroTemplateDefinitionType
  class HeroDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include TimestampScopes

    layout_kind! :hero
    template_kind! :hero

    graphql_node_type_name "::Types::Templates::HeroTemplateDefinitionType"

    pg_enum! :background, as: :hero_background, allow_blank: false, suffix: :background, default: "none"

    attribute :slots, ::Templates::SlotMappings::HeroDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::HeroDefinition",
      inverse_of: :hero_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::HeroInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
