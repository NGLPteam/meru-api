# frozen_string_literal: true

module Types
  module Layouts
    # @see ::Layouts::MainInstance
    class MainLayoutInstanceType < ::Types::BaseModel
      implements ::Types::LayoutInstanceType

      field :layout_definition, Types::Layouts::MainLayoutDefinitionType, null: false do
        description <<~TEXT
        The layout definition for this type.
        TEXT
      end

      field :templates, [Types::AnyMainTemplateInstanceType, { null: false }], null: false do
        description <<~TEXT
        The ordered template instances available for this layout.
        TEXT
      end

      ::Layouts::MainInstance.template_instance_names.each do |name|
        load_association! name
      end
    end
  end
end
