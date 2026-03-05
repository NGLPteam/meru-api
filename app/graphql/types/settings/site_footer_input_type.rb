# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::SiteFooter
    class SiteFooterInputType < Types::HashInputObject
      description <<~TEXT
      A value for updating the site's configuration.
      TEXT

      argument :description, String, required: false do
        description <<~TEXT
        A description that lives in the site's footer.
        TEXT
      end

      argument :copyright_statement, String, required: false do
        description <<~TEXT
        A copyright statement that lives in the site's footer.
        TEXT
      end
    end
  end
end
