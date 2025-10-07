# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      class Templates < Abstract
        include Harvesting::Extraction::Constants

        attribute :templates, ::Harvesting::Extraction::Mappings::Template, collection: true, default: -> { [] }

        xml do
          root "templates"

          map_element "template", to: :templates
        end

        # @param [String] name
        # @return [String, nil]
        def lookup_template(name)
          templates.find { _1.name == name }&.template
        end
      end
    end
  end
end
