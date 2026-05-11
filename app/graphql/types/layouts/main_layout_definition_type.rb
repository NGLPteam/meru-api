# frozen_string_literal: true

module Types
  module Layouts
    # @see ::Layouts::MainDefinition
    class MainLayoutDefinitionType < ::Types::BaseModel
      implements ::Types::LayoutDefinitionType

      field :templates, [Types::AnyMainTemplateDefinitionType, { null: false }], null: false do
        description <<~TEXT
        The ordered template definitions available for this layout.
        TEXT
      end

      ::Layouts::MainDefinition.template_definition_names.each do |name|
        load_association! name
      end
    end
  end
end
