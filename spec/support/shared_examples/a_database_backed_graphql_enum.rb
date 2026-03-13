# frozen_string_literal: true

RSpec.shared_examples_for "a database-backed graphql enum" do |enum_name, symbolic: false|
  context "within the #{enum_name} PG enum" do
    let_it_be(:pg_enum_values) { ApplicationRecord.pg_enum_values(enum_name).map { |value| symbolic ? value.to_sym : value } }

    let_it_be(:known_values) { described_class.values.values.map(&:value) }

    it "matches what is in postgres" do
      expect(known_values).to match_array pg_enum_values
    end

    ApplicationRecord.pg_enum_values(enum_name).map { |value| symbolic ? value.to_sym : value }.each do |enum_value|
      it "accepts the #{enum_value.inspect} value" do
        expect(described_class.name_for_value(enum_value)).to be_present
      end
    end
  end
end
