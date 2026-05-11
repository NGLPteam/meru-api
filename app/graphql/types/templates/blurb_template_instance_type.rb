# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::BlurbInstance
    class BlurbTemplateInstanceType < ::Types::BaseModel
      implements ::Types::TemplateInstanceType

      field :definition, ::Types::Templates::BlurbTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::BlurbTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
