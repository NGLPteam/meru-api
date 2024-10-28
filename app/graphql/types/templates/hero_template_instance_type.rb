# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::HeroInstance
    class HeroTemplateInstanceType < AbstractModel
      implements ::Types::TemplateInstanceType

      field :definition, ::Types::Templates::HeroTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::HeroTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
