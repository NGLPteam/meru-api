# frozen_string_literal: true

module Harvesting
  module Extraction
    # A liquid filesystem that will try to look up defined templates
    # within an extraction mapping.
    class FileSystem
      include Dry::Effects.Reader(:render_context)

      # @param [String] name
      # @raise [Liquid::FileSystemError]
      # @return [String]
      def read_template_file(name)
        body = render_context.mapping.lookup_template(name)

        # :nocov:
        raise Liquid::FileSystemError, "No such template '#{name}'" unless body
        # :nocov:

        return body
      end
    end
  end
end
