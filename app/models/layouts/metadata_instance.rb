# frozen_string_literal: true

module Layouts
  # @see Layouts::MetadataDefinition
  # @see Types::Layouts::MetadataLayoutInstanceType
  # @see Templates::MetadataInstance
  class MetadataInstance < ApplicationRecord
    include HasEphemeralSystemSlug
    include LayoutInstance
    include TimestampScopes

    graphql_node_type_name "::Types::Layouts::MetadataLayoutInstanceType"

    layout_kind! :metadata
    template_kinds! ["metadata"].freeze

    belongs_to :layout_definition, class_name: "Layouts::MetadataDefinition", inverse_of: :layout_instances

    has_many :metadata_template_instances,
      -> { for_preloading },
      class_name: "Templates::MetadataInstance",
      dependent: :destroy,
      inverse_of: :layout_instance,
      foreign_key: :layout_instance_id

    has_one :template_instance,
      -> { for_preloading },
      class_name: "Templates::MetadataInstance",
      dependent: :destroy,
      inverse_of: :layout_instance,
      foreign_key: :layout_instance_id

    has_one :schema_version, through: :layout_definition

    # Dependencies that get preloaded in GraphQL.
    # Layouts and templates have a pretty large tree, but relying
    # on typical dataloading just won't work for our purposes.
    LAYOUT_INSTANCE_DEPENDENCIES = {
      layout_definition: [],
      metadata_template_instances: [],
      template_instance: [],
    }.freeze

    class << self
      def preloaded_for_record_loading
        super.includes(LAYOUT_INSTANCE_DEPENDENCIES)
      end
    end
  end
end
