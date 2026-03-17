# frozen_string_literal: true

RSpec.shared_examples_for "an entity with schematic properties" do |var_name|
  let!(:entity) { public_send(var_name) }

  it "can write schematic text references" do
    expect(entity.write_schematic_texts).to be_a_monadic_success
  end

  it "can extract orderable properties" do
    expect(entity.extract_orderable_properties).to be_a_monadic_success
  end

  it "can extract searchable properties" do
    expect(entity.extract_searchable_properties).to be_a_monadic_success
  end

  it "can reindex itself" do
    expect(entity.reindex).to be_a_monadic_success
  end

  context "when reading properties" do
    it "serializes without issue" do
      expect do
        entity.read_property_context.field_values
      end.not_to raise_error
    end
  end
end
