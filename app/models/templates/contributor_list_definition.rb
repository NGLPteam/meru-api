# frozen_string_literal: true

module Templates
  # @see Layouts::MainDefinition
  # @see Templates::ContributorListInstance
  # @see Templates::Config::Template::ContributorList
  # @see Templates::SlotMappings::ContributorListDefinitionSlots
  # @see Types::Templates::ContributorListTemplateDefinitionType
  class ContributorListDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateDefinition
    include Templates::Definitions::HasContributionList
    include TimestampScopes

    layout_kind! :main
    template_kind! :contributor_list

    graphql_node_type_name "::Types::Templates::ContributorListTemplateDefinitionType"

    pg_enum! :background, as: :contributor_list_background, allow_blank: false, suffix: :background, default: "none"

    pg_enum! :filter, as: :contributor_list_filter, allow_blank: false, suffix: :filter, default: "all"

    pg_enum! :width, as: :template_width, allow_blank: false, suffix: :width, default: "full"

    attribute :slots, ::Templates::SlotMappings::ContributorListDefinitionSlots.to_type

    belongs_to :layout_definition,
      -> { for_preloading },
      class_name: "Layouts::MainDefinition",
      inverse_of: :contributor_list_template_definitions

    has_many :template_instances,
      -> { for_preloading },
      class_name: "Templates::ContributorListInstance",
      dependent: :destroy,
      inverse_of: :template_definition,
      foreign_key: :template_definition_id
  end
end
