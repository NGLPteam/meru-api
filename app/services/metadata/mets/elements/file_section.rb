# frozen_string_literal: true

module Metadata
  module METS
    module Elements
      class FileSection < ::Metadata::METS::Common::AbstractMapper
        include Metadata::METS::Common::EnumeratesFiles

        attribute :id, ::Metadata::Shared::Xsd::Id
        attribute :file_groups, Metadata::METS::Elements::FileGroup, collection: true

        xml do
          root "fileSec", mixed: true

          namespace "http://www.loc.gov/METS/"

          map_attribute "ID", to: :id

          map_element "fileGrp", to: :file_groups
        end

        def each_file
          # simplecov:disable
          return enum_for(__method__) unless block_given?
          # simplecov:enable

          Array(file_groups).each do |group|
            group.each_file do |file|
              yield file
            end
          end
        end
      end
    end
  end
end
