# frozen_string_literal: true

module Harvesting
  module Extraction
    # @see LiquidExt::CommonFilters
    module CommonFilters
      # @param [#to_s] input
      # @return [String]
      def parameterize(input)
        input.to_s.parameterize
      end

      # @param [#to_s] input
      # @return [ActiveSupport::SafeBuffer]
      def unescape_html(input)
        CGI.unescapeHTML(input.to_s).html_safe
      end
    end
  end
end
