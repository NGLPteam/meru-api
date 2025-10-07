# frozen_string_literal: true

module Harvesting
  module Extraction
    module Mappings
      class SchemaProperties < Harvesting::Extraction::Mappings::Props::AbstractSet
        accept_props! Harvesting::Extraction::Mappings::Props::Asset
        accept_props! Harvesting::Extraction::Mappings::Props::Boolean
        accept_props! Harvesting::Extraction::Mappings::Props::ControlledVocabulary
        accept_props! Harvesting::Extraction::Mappings::Props::Date
        accept_props! Harvesting::Extraction::Mappings::Props::Email
        accept_props! Harvesting::Extraction::Mappings::Props::Float
        accept_props! Harvesting::Extraction::Mappings::Props::FullText
        accept_props! Harvesting::Extraction::Mappings::Props::Integer
        accept_props! Harvesting::Extraction::Mappings::Props::String
        accept_props! Harvesting::Extraction::Mappings::Props::Tags
        accept_props! Harvesting::Extraction::Mappings::Props::Timestamp
        accept_props! Harvesting::Extraction::Mappings::Props::URL
        accept_props! Harvesting::Extraction::Mappings::Props::VariableDate

        klasses = prop_klasses

        xml do
          root "properties"

          klasses.each do |klass|
            map_element klass.property_root, to: klass.property_attr
          end
        end

        # @return [{ String => Harvesting::Extraction::Mappings::Props::Base }]
        def props
          @props ||= to_prop_set
        end
      end
    end
  end
end
