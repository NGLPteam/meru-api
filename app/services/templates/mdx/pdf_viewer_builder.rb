# frozen_string_literal: true

module Templates
  module MDX
    # Works very similar to {Templates::MDX::AssetBuilder},
    # except semantically it is for rendering a PDF.
    #
    # @see Templates::MDX::BuildPDFViewer
    class PDFViewerBuilder < ::Templates::MDX::AbstractBuilder
      tag_name "PDFViewer"

      option :asset, Templates::Types::Asset

      option :url, Templates::Types::String, default: proc { asset.view_url }

      delegate :file_size, :original_filename, :system_slug, to: :asset

      alias name original_filename
      alias slug system_slug
      alias size file_size

      def build_attributes
        super.merge(
          name:,
          size:,
          slug:,
          url:
        )
      end

      def build_inner_html
        name.presence || "asset.pdf"
      end
    end
  end
end
