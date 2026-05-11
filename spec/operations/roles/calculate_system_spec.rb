# frozen_string_literal: true

RSpec.describe Roles::CalculateSystem, type: :operation do
  it "calculates the expected amount of roles" do
    expect_calling.to succeed.with(have(7).items)
  end
end
