# frozen_string_literal: true

module Types
  module Templates
    # @see ::Templates::ContributorListInstance
    class ContributorListTemplateInstanceType < ::Types::BaseModel
      implements ::Types::TemplateInstanceType
      implements ::Types::TemplateHasContributionListType

      field :definition, ::Types::Templates::ContributorListTemplateDefinitionType, null: false do
        description <<~TEXT
        Load the associated definition for this template.
        TEXT
      end

      field :slots, ::Types::Templates::ContributorListTemplateInstanceSlotsType, null: false do
        description <<~TEXT
        Rendered slots for this template.
        TEXT
      end

      load_association! :template_definition, as: :definition
    end
  end
end
