# frozen_string_literal: true

module Layouts
  # @see Layouts::SupplementaryInstance
  # @see Types::Layouts::SupplementaryLayoutDefinitionType
  # @see Templates::SupplementaryDefinition
  class SupplementaryDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutDefinition
    include TimestampScopes

    layout_kind! :supplementary
    template_kinds! ["supplementary"].freeze

    graphql_node_type_name "::Types::Layouts::SupplementaryLayoutDefinitionType"

    belongs_to :schema_version, inverse_of: :supplementary_layout_definitions
    belongs_to :entity, polymorphic: true, optional: true

    has_many :layout_instances,
      -> { for_preloading },
      class_name: "Layouts::SupplementaryInstance",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :supplementary_template_definitions,
      -> { for_preloading },
      class_name: "Templates::SupplementaryDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_one :template_definition,
      -> { for_preloading },
      class_name: "Templates::SupplementaryDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id
  end
end
