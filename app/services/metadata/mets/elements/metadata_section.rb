# frozen_string_literal: true

module Metadata
  module METS
    module Elements
      # Can be any sort of metadata section, like `<techMD/>`, `<rightsMD/>`, `<sourceMD/>`, `<digiprovMD/>` or `<dmdSec />`.
      class MetadataSection < ::Metadata::METS::Common::AbstractMapper
        attribute :id, ::Metadata::Shared::Xsd::Id
        attribute :groupid, :string
        attribute :admid, ::Metadata::Shared::Xsd::IdRefs
        attribute :created, :date_time
        attribute :status, :string

        attribute :referenced_metadata, ::Metadata::METS::Elements::MetadataReference

        attribute :wrapped_metadata, ::Metadata::METS::Elements::MetadataWrapper

        attribute :metadata_kind, method: :calculated_metadata_kind

        attribute :metadata, method: :calculated_metadata

        xml do
          root "mdSec", mixed: true

          namespace "http://www.loc.gov/METS/"

          map_attribute "ID", to: :id
          map_attribute "GROUPID", to: :groupid
          map_attribute "ADMID", to: :admid
          map_attribute "CREATED", to: :created
          map_attribute "STATUS", to: :status

          map_element :mdRef, to: :referenced_metadata
          map_element :mdWrap, to: :wrapped_metadata
        end

        # @api private
        def calculated_metadata
          case metadata_kind
          in "wrapped"
            wrapped_metadata
          in "referenced"
            referenced_metadata
          else
            # simplecov:disable
            return false
            # simplecov:enable
          end
        end

        # @api private
        def calculated_metadata_kind
          if wrapped_metadata.present?
            "wrapped"
          elsif referenced_metadata.present?
            "referenced"
          else
            "unknown"
          end
        end
      end
    end
  end
end
