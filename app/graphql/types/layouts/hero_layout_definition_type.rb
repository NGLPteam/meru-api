# frozen_string_literal: true

module Types
  module Layouts
    # @see ::Layouts::HeroDefinition
    class HeroLayoutDefinitionType < ::Types::BaseModel
      implements ::Types::LayoutDefinitionType

      field :templates, [Types::AnyHeroTemplateDefinitionType, { null: false }], null: false do
        description <<~TEXT
        The ordered template definitions available for this layout.
        TEXT
      end

      field :template, "Types::Templates::HeroTemplateDefinitionType", null: true do
        description <<~TEXT
        This layout will only ever have one template, so it can be fetched directly without needing the union.
        TEXT
      end

      load_association! :template_definition, as: :template

      ::Layouts::HeroDefinition.template_definition_names.each do |name|
        load_association! name
      end
    end
  end
end
