# frozen_string_literal: true

module Seeding
  module Import
    module Structs
      # A struct for building a {::Community}.
      class Community < Base
        include ::Support::Typing

        attribute :identifier, Seeding::Types::String
        attribute :title, Seeding::Types::String
        attribute :schema, Seeding::Types::CommunitySchema

        attribute? :collections, Seeding::Import::Structs::Collections::AnyList
        attribute? :pages, Seeding::Import::Structs::Page.as_list

        attribute? :logo, Seeding::Import::Structs::Assets::Any.optional
        attribute? :hero_image, Seeding::Import::Structs::Assets::Any.optional
        attribute? :thumbnail, Seeding::Import::Structs::Assets::Any.optional

        def images
          slice(:hero_image, :logo, :thumbnail)
        end
      end
    end
  end
end
