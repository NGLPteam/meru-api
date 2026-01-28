# frozen_string_literal: true

RSpec.describe System::Check, type: :operation do
  it "refreshes a number of internal counters" do
    expect_calling.to succeed.with(a_kind_of(Hash))
  end
end
