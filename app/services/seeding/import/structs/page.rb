# frozen_string_literal: true

module Seeding
  module Import
    module Structs
      # A struct for building a {::Page}.
      class Page < Base
        include ::Support::Typing

        DefaultList = List.default { [] }

        attribute :slug, Support::GlobalTypes::Slug
        attribute :title, Seeding::Types::String
        attribute :body, Seeding::Types::String
        attribute? :hero_image, Seeding::Import::Structs::Assets::Any.optional

        def blank?
          slug.blank? || title.blank? || body.blank?
        end

        def assignable_attributes
          slice(:title, :body)
        end

        def images
          slice(:hero_image)
        end
      end
    end
  end
end
