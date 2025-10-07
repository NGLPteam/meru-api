# frozen_string_literal: true

module Harvesting
  module Extraction
    class Mapping < Harvesting::Extraction::Mappings::Abstract
      attribute :assigns, Harvesting::Extraction::Mappings::Assigns
      attribute :contribution_mapping, Harvesting::Extraction::Mappings::ContributionMapping
      attribute :entity_mapping, Harvesting::Extraction::Mappings::EntityMapping
      attribute :template_mapping, ::Harvesting::Extraction::Mappings::Templates

      xml do
        root "mapping"

        map_element "assigns", to: :assigns
        map_element "contributions", to: :contribution_mapping
        map_element "entities", to: :entity_mapping
        map_element "templates", to: :template_mapping
      end

      delegate :each_shared_assignment, to: :assigns, allow_nil: true
      delegate :lookup_template, to: :template_mapping, allow_nil: true, prefix: :actually

      # @param [String] name
      # @return [String, nil]
      def lookup_template(name)
        actually_lookup_template(name)
      end

      # @see Harvesting::Extraction::Mappings::EntityMapping
      # @return [<String>]
      def schema_declarations
        Array(entity_mapping.try(:schema_declarations))
      end

      # @return [Harvesting::Extraction::Contributions::Config]
      def to_contributions_config
        contribution_mapping&.to_config || Harvesting::Extraction::Contributions::Config.new
      end

      def has_assigns?
        assigns.present?
      end

      def has_entities?
        entity_mapping.present?
      end
    end
  end
end
