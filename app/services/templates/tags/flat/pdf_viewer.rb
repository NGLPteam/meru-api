# frozen_string_literal: true

module Templates
  module Tags
    module Flat
      class PDFViewer < AbstractTag
        args! :source

        def render(context)
          asset = args.asset(:source, context, allow_blank: true)

          return if asset.blank?

          # simplecov:disable
          raise Liquid::ContextError, "Expected #{args[:source].expression.inspect} to be a PDF asset" unless asset.pdf?
          # simplecov:enable

          call_operation!("templates.mdx.build_pdf_viewer", asset:)
        end
      end
    end
  end
end
