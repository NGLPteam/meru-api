# frozen_string_literal: true

module Resolvers
  class AssetResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::SimplyOrdered

    type Types::AssetType.connection_type, null: false

    scope { object.present? ? object.assets : Asset.none }

    option :kind, type: Types::AssetKindFilterType, default: "ALL"

    def apply_kind_with_all(scope)
      scope.all
    end

    def apply_kind_with_audio(scope)
      scope.audios
    end

    def apply_kind_with_image(scope)
      scope.images
    end

    def apply_kind_with_video(scope)
      scope.videos
    end

    def apply_kind_with_media(scope)
      scope.media
    end

    def apply_kind_with_pdf(scope)
      scope.pdfs
    end

    def apply_kind_with_document(scope)
      scope.documents
    end
  end
end
