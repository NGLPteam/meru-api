# frozen_string_literal: true

module Templates
  # @see Layouts::MainInstance
  # @see Templates::ContributorListDefinition
  # @see Templates::SlotMappings::ContributorListInstanceSlots
  # @see Types::Templates::ContributorListTemplateInstanceType
  class ContributorListInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include TemplateInstance
    include Templates::Instances::HasContributionList
    include TimestampScopes

    layout_kind! :main
    template_kind! :contributor_list

    attribute :slots, ::Templates::SlotMappings::ContributorListInstanceSlots.to_type

    graphql_node_type_name "::Types::Templates::ContributorListTemplateInstanceType"

    belongs_to :layout_instance,
      -> { for_preloading },
      class_name: "Layouts::MainInstance",
      inverse_of: :contributor_list_template_instances

    belongs_to :template_definition,
      -> { for_preloading },
      class_name: "Templates::ContributorListDefinition",
      inverse_of: :template_instances

    has_one :layout_definition, through: :layout_instance

    has_one :schema_version, through: :layout_definition

    belongs_to :entity, polymorphic: true
  end
end
