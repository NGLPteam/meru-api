# frozen_string_literal: true

module Layouts
  # @see Layouts::MetadataInstance
  # @see Types::Layouts::MetadataLayoutDefinitionType
  # @see Templates::MetadataDefinition
  class MetadataDefinition < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutDefinition
    include TimestampScopes

    layout_kind! :metadata
    template_kinds! ["metadata"].freeze

    graphql_node_type_name "::Types::Layouts::MetadataLayoutDefinitionType"

    belongs_to :schema_version, inverse_of: :metadata_layout_definitions
    belongs_to :entity, polymorphic: true, optional: true

    has_many :layout_instances,
      -> { for_preloading },
      class_name: "Layouts::MetadataInstance",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_many :metadata_template_definitions,
      -> { for_preloading },
      class_name: "Templates::MetadataDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id

    has_one :template_definition,
      -> { for_preloading },
      class_name: "Templates::MetadataDefinition",
      dependent: :destroy,
      inverse_of: :layout_definition,
      foreign_key: :layout_definition_id
  end
end
