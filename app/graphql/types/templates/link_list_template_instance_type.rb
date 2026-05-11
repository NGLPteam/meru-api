# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::LinkListInstance
    class LinkListTemplateInstanceType < ::Types::BaseModel
      implements ::Types::TemplateInstanceType
      implements ::Types::TemplateHasEntityListType
      implements ::Types::TemplateHasSeeAllOrderingType

      field :definition, ::Types::Templates::LinkListTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::LinkListTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
