# frozen_string_literal: true

module Types
  module Layouts
    # @see ::Layouts::HeroInstance
    class HeroLayoutInstanceType < ::Types::BaseModel
      implements ::Types::LayoutInstanceType

      field :layout_definition, Types::Layouts::HeroLayoutDefinitionType, null: false do
        description <<~TEXT
        The layout definition for this type.
        TEXT
      end

      field :templates, [Types::AnyHeroTemplateInstanceType, { null: false }], null: false do
        description <<~TEXT
        The ordered template instances available for this layout.
        TEXT
      end

      field :template, "Types::Templates::HeroTemplateInstanceType", null: true do
        description <<~TEXT
        This layout will only ever have one template, so it can be fetched directly without needing the union.
        TEXT
      end

      load_association! :template_instance, as: :template

      ::Layouts::HeroInstance.template_instance_names.each do |name|
        load_association! name
      end
    end
  end
end
