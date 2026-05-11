# frozen_string_literal: true

module Types
  module Layouts
    # @see ::Layouts::ListItemDefinition
    class ListItemLayoutDefinitionType < ::Types::BaseModel
      implements ::Types::LayoutDefinitionType

      field :templates, [Types::AnyListItemTemplateDefinitionType, { null: false }], null: false do
        description <<~TEXT
        The ordered template definitions available for this layout.
        TEXT
      end

      field :template, "Types::Templates::ListItemTemplateDefinitionType", null: true do
        description <<~TEXT
        This layout will only ever have one template, so it can be fetched directly without needing the union.
        TEXT
      end

      load_association! :template_definition, as: :template

      ::Layouts::ListItemDefinition.template_definition_names.each do |name|
        load_association! name
      end
    end
  end
end
