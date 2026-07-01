# frozen_string_literal: true

module Metadata
  module METS
    module Elements
      class MetadataWrapper < ::Metadata::METS::Common::AbstractMapper
        include Dry::Core::Memoizable

        include Metadata::METS::AttributeGroups::FileCore
        include Metadata::METS::AttributeGroups::Metadata

        attribute :id, ::Metadata::Shared::Xsd::Id
        attribute :label, :string
        attribute :bin_data, ::Metadata::Shared::Xsd::Base64Binary
        attribute :xml_data, ::Metadata::METS::Elements::XMLData

        attribute :mods, method: :calculated_mods_content
        attribute :premis, method: :calculated_premis_content

        delegate :content, to: :xml_data, prefix: :xml, allow_nil: true

        xml do
          root "mdWrap", mixed: true

          namespace "http://www.loc.gov/METS/"

          map_attribute "ID", to: :id
          map_attribute "LABEL", to: :label

          map_element :binData, to: :bin_data
          map_element :xmlData, to: :xml_data
        end

        memoize def calculated_mods_content
          parse_root_with("metadata.mods.parse_root", "MODS")
        end

        memoize def calculated_premis_content
          parse_root_with("metadata.premis.parse_root", "PREMIS")
        end

        private

        def parse_root_with(operation_name, *types)
          # simplecov:disable
          return unless types.present? && types.any? { mdtype == _1 }
          # simplecov:enable

          MeruAPI::Container[operation_name].(xml_content).value_or(nil)
        end
      end
    end
  end
end
