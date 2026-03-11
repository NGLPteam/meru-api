# frozen_string_literal: true

module Templates
  module Config
    module Utility
      # Very specific utility types for the config namespace within the templating subsystem.
      module Types
        extend ::Support::Typespace

        LayoutConfigKlass = Inherits(::Templates::Config::Utility::AbstractLayout)

        TemplateConfigKlass = Inherits(::Templates::Config::Utility::AbstractTemplate)

        PolymorphicTemplateMapping = Hash.map(Coercible::String, TemplateConfigKlass)
      end
    end
  end
end
