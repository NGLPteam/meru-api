# frozen_string_literal: true

RSpec.describe ControlledVocabularies::Upsert, type: :operation do
  let(:nested_definition) do
    {
      namespace: "meru.host",
      identifier: "nested",
      name: "Nested Test",
      version: "1.0.0",
      provides: "unit",
      items: [
        {
          identifier: "foo",
          label: "Foo",
          children: [
            {
              identifier: "bar",
              label: "Bar",
              children: [
                {
                  identifier: "baz",
                  label: "Baz",
                },
              ]
            }
          ]
        }
      ]
    }
  end

  it "can upsert a nested definition" do
    expect do
      expect_calling_with(nested_definition).to succeed
    end.to change(ControlledVocabulary, :count).by(1)
      .and change(ControlledVocabularyItem, :count).by(3)
  end
end
