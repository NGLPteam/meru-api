# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      class Template < Abstract
        include Harvesting::Extraction::Constants

        attribute :name, ::Mappers::StrippedString

        attribute :template, ::Mappers::StrippedString

        xml do
          root "template"

          map_attribute "name", to: :name

          map_content to: :template
        end
      end
    end
  end
end
