# frozen_string_literal: true

module Support
  module GQL
    class SimpleOrderType < Support::GQL::BaseEnum
      description <<~TEXT
      A generic enum for sorting models that don't have anything more specific implemented.
      TEXT

      value "RECENT" do
        description <<~TEXT
        Sort models by newest created date.
        TEXT
      end

      value "OLDEST" do
        description <<~TEXT
        Sort models by oldest created date.
        TEXT
      end
    end
  end
end
