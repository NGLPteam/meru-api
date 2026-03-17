# frozen_string_literal: true

RSpec.describe SchemaDefinitionProperty, type: :model do
  context "when a schema has multiple versions" do
    let_it_be(:definition, refind: true) { FactoryBot.create :schema_definition, :simple_item }
    let_it_be(:v1, refind: true) { FactoryBot.create :schema_version, :simple_item, :v1 }
    let_it_be(:v2, refind: true) { FactoryBot.create :schema_version, :simple_item, :v2 }

    context "with property found only in one version" do
      let!(:property) do
        described_class.refresh!

        described_class.fetch definition, "bar.quux"
      end

      subject { property }

      it "covers only one version" do
        expect(property).to have_attributes(covered_version_ids: [v2.id])
      end
    end

    context "with a property that spans versions" do
      let!(:property) do
        described_class.refresh!

        described_class.fetch definition, "foo"
      end

      it "has a reference to each version" do
        expect(property.covered_version_ids).to contain_exactly v1.id, v2.id
      end
    end
  end
end
