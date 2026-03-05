# frozen_string_literal: true

module Types
  class DepositorRequestStateType < Types::BaseEnum
    description <<~TEXT
    Depositor request state enum
    TEXT

    value "PENDING", value: "pending" do
      description <<~TEXT
      TEXT
    end

    value "APPROVED", value: "approved" do
      description <<~TEXT
      TEXT
    end

    value "REJECTED", value: "rejected" do
      description <<~TEXT
      TEXT
    end
  end
end
