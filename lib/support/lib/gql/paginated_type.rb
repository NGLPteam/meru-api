# frozen_string_literal: true

module Support
  module GQL
    module PaginatedType
      include ::Support::GQL::BaseInterface

      description <<~TEXT
      Connections can be paginated by cursor or number.
      TEXT

      field :page_info, ::Support::GQL::PageInfoType, null: false do
        description <<~TEXT
        Information to aid in pagination.
        TEXT
      end
    end
  end
end
