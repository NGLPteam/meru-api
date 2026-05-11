# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::ListItemInstance
    class ListItemTemplateInstanceType < ::Types::BaseModel
      implements ::Types::TemplateInstanceType
      implements ::Types::TemplateHasEntityListType
      implements ::Types::TemplateHasSeeAllOrderingType

      field :definition, ::Types::Templates::ListItemTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::ListItemTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
