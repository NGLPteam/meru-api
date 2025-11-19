# frozen_string_literal: true

module Types
  # @see Templates::EntityList
  # @see Templates::Definitions::HasEntityList
  # @see Templates::Instances::HasEntityList
  # @see Types::TemplateEntityListType
  module TemplateHasEntityListType
    include Types::BaseInterface

    description <<~TEXT
    An interface for a template instance that has a `TemplateEntityList`.
    TEXT

    field :entity_list, ::Types::TemplateEntityListType, null: false do
      description <<~TEXT
      The list of entities to render as part of this template's content.
      TEXT
    end

    load_association! :cached_entity_list

    def entity_list
      cached_entity_list.then do |cel|
        cel.presence || ::Templates::EntityList.new
      end
    end
  end
end
