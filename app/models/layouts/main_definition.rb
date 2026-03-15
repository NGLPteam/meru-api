# frozen_string_literal: true

module Layouts
  # @see Layouts::MainInstance
  # @see Types::Layouts::MainLayoutDefinitionType
  # @see Templates::BlurbDefinition
  # @see Templates::DetailDefinition
  # @see Templates::DescendantListDefinition
  # @see Templates::LinkListDefinition
  # @see Templates::PageListDefinition
  # @see Templates::ContributorListDefinition
  # @see Templates::OrderingDefinition
  class MainDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutDefinition
    include TimestampScopes

    layout_kind! :main
    template_kinds! ["detail", "descendant_list", "link_list", "page_list", "contributor_list", "ordering", "blurb"].freeze

    graphql_node_type_name "::Types::Layouts::MainLayoutDefinitionType"

    belongs_to :schema_version, inverse_of: :main_layout_definitions
    belongs_to :entity, polymorphic: true, optional: true

    has_many :layout_instances,
      -> { for_preloading },
      class_name: "Layouts::MainInstance",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :blurb_template_definitions,
      -> { for_preloading },
      class_name: "Templates::BlurbDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :detail_template_definitions,
      -> { for_preloading },
      class_name: "Templates::DetailDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :descendant_list_template_definitions,
      -> { for_preloading },
      class_name: "Templates::DescendantListDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :link_list_template_definitions,
      -> { for_preloading },
      class_name: "Templates::LinkListDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :page_list_template_definitions,
      -> { for_preloading },
      class_name: "Templates::PageListDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :contributor_list_template_definitions,
      -> { for_preloading },
      class_name: "Templates::ContributorListDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :ordering_template_definitions,
      -> { for_preloading },
      class_name: "Templates::OrderingDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id
  end
end
