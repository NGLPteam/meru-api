# frozen_string_literal: true

module Types
  module Settings
    # @see ::Settings::SiteFooter
    class SiteFooterType < Types::BaseObject
      description <<~TEXT
      A value for updating the site's configuration.
      TEXT

      field :description, String, null: false do
        description <<~TEXT
        A description that lives in the site's footer.
        TEXT
      end

      field :copyright_statement, String, null: false do
        description <<~TEXT
        A copyright statement that lives in the site's footer.
        TEXT
      end
    end
  end
end
