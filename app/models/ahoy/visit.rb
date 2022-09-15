# frozen_string_literal: true

# @api private
module Ahoy
  class Visit < ApplicationRecord
    self.rollup_column = :started_at
    self.table_name = "ahoy_visits"

    has_many :events, class_name: "Ahoy::Event", inverse_of: :visit, dependent: :delete_all

    belongs_to :user, optional: true
  end
end
