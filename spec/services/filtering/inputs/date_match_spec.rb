# frozen_string_literal: true

RSpec.describe ::Support::Filtering::Inputs::DateMatch do
  let(:gt) { Date.new(2023, 1, 1) }
  let(:not_eq) { Date.new(2023, 6, 15) }
  let(:lt) { Date.new(2023, 12, 31) }

  let(:attribute) { Arel::Table.new(:records)[:created_at] }

  let(:matcher) { described_class.new(gt:, lt:, not_eq:) }

  it "can compile to arel expressions", :aggregate_failures do
    expression = matcher.call(attribute)

    sql = expression.to_sql

    expect(matcher).not_to be_blank
    expect(matcher).to have_comparator(:gt)
    expect(matcher).to have_comparator(:lt)
    expect(matcher).to have_comparator(:not_eq)
    expect(matcher).not_to have_comparator(:eq)

    expect(sql).to include('"records"."created_at" > \'2023-01-01\'')
    expect(sql).to include('"records"."created_at" < \'2023-12-31\'')
    expect(sql).to include('"records"."created_at" != \'2023-06-15\'')
  end

  context "when no comparators are set" do
    let(:matcher) { described_class.new }

    it "returns nil" do
      expect(matcher.call(attribute)).to be_nil
    end
  end

  describe ".input_object" do
    let(:comparators) do
      {
        gt:,
        lt:,
        not_eq:,
      }
    end

    let(:instance) { described_class.new(**comparators) }
    let(:input_object) { described_class.build_input_object(**comparators) }

    it "prepares into a struct" do
      expect(input_object.prepare).to eq instance
    end
  end
end
