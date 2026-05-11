# frozen_string_literal: true

module Support
  module GQL
    class PageDirectionType < ::Support::GQL::BaseEnum
      description <<~TEXT
      Determines the direction that page-number based pagination should flow
      TEXT

      value "FORWARDS", value: :forwards do
        description <<~TEXT
        Indicates that page-number based pagination should flow in ascending order (1-9)
        TEXT
      end

      value "BACKWARDS", value: :backwards do
        description <<~TEXT
        Indicates that page-number based pagination should flow in descending order (9-1)
        TEXT
      end
    end
  end
end
