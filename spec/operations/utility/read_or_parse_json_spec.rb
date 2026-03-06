# frozen_string_literal: true

RSpec.describe Utility::ReadOrParseJSON, type: :operation do
  let(:valid_path) { Rails.root.join "spec", "data", "sample_import.json" }
  let(:invalid_path) { Rails.root.join("does", "not", "exist.json") }

  it "succeeds with an existing pathname" do
    expect_calling_with(valid_path).to succeed.with(a_kind_of(Hash))
  end

  it "succeeds with an existing pathname as a string" do
    expect_calling_with(valid_path.to_s).to succeed.with(a_kind_of(Hash))
  end

  it "fails with a non-existing path" do
    expect_calling_with(invalid_path).to be_a_monadic_failure
  end

  it "fails with a non-existing path string" do
    expect_calling_with(invalid_path.to_s).to be_a_monadic_failure
  end

  it "succeeds with encoded JSON" do
    expect_calling_with(%[{ "foo": "bar" }]).to succeed.with({ "foo" => "bar" })
  end

  it "fails with invalid encoded JSON" do
    expect_calling_with(%[{ "Some"": invalid json }]).to be_a_monadic_failure
  end

  it "succeeds with an arbitrary hash" do
    expect_calling_with({ foo: :bar }).to succeed.with(foo: :bar)
  end

  it "succeeds with an arbitrary array" do
    expect_calling_with([ { foo: :bar }]).to succeed.with([{ foo: :bar }])
  end

  it "fails with anything else" do
    expect_calling_with(true).to be_a_monadic_failure
  end
end
