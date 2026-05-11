# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::OrderingInstance
    class OrderingTemplateInstanceType < ::Types::BaseModel
      implements ::Types::TemplateInstanceType
      implements ::Types::TemplateHasOrderingPairType

      field :definition, ::Types::Templates::OrderingTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::OrderingTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
