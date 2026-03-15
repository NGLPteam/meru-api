# frozen_string_literal: true

module TestHelpers
  module ControlledVocab
    module ExampleHelpers
      CV_ROOT = Rails.root.join("lib", "controlled_vocabularies")

      CV_EMPTY = {
        namespace: "meru.host",
        identifier: "empty",
        name: "Empty",
        version: "1.0.0",
        provides: "unit",
        items: []
      }.freeze

      CV_NOT_UNIQUE = {
        namespace: "meru.host",
        identifier: "not_unique",
        name: "Not Unique",
        version: "1.0.0",
        provides: "unit",
        items: [
          {
            identifier: "foo",
            label: "Foo",
          },
          {
            identifier: "foo",
            label: "Foo"
          },
        ]
      }.freeze

      CV_TOO_DEEP = {
        namespace: "meru.host",
        identifier: "too_deep",
        name: "Too Deep",
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
                    children: [
                      {
                        identifier: "quux",
                        label: "Quux",
                      }
                    ],
                  },
                ]
              }
            ]
          }
        ]
      }.freeze

      def cv_def_empty
        CV_EMPTY
      end

      def cv_def_not_unique
        CV_NOT_UNIQUE
      end

      def cv_def_too_deep
        CV_TOO_DEEP
      end

      def cv_definition_for(identifier, namespace: "meru.host", version: "1.0.0", root: CV_ROOT)
        path = root.join(namespace, identifier, "#{version}.json")

        JSON.parse path.read
      end

      # @param [Hash] definition
      # @return [ControlledVocabulary]
      def upsert_cv!(definition)
        MeruAPI::Container["controlled_vocabularies.upsert"].(definition).value!
      end
    end
  end
end

RSpec.shared_context "cv::test_unit" do
  let_it_be(:cv_test_unit_definition) do
    {
      namespace: "meru.test",
      identifier: "test_units",
      name: "Test Units",
      version: "1.0.0",
      provides: "test_units",
      items: [
        {
          identifier: "foo",
          label: "Foo",
        },
        {
          identifier: "bar",
          label: "Bar",
        },
        {
          identifier: "baz",
          label: "Baz",
        },
        {
          identifier: "quux",
          label: "Quux",
        }
      ]
    }
  end

  let_it_be(:cv_test_unit, refind: true) do
    upsert_cv!(cv_test_unit_definition).tap do |cv|
      cv.select_provider!
    end
  end

  let_it_be(:cv_test_unit_foo, refind: true) do
    cv_test_unit.item_for(:foo)
  end

  let_it_be(:cv_test_unit_bar, refind: true) do
    cv_test_unit.item_for(:bar)
  end

  let_it_be(:cv_test_unit_baz, refind: true) do
    cv_test_unit.item_for(:baz)
  end

  let_it_be(:cv_test_unit_quux, refind: true) do
    cv_test_unit.item_for(:quux)
  end
end

RSpec.configure do |config|
  config.include TestHelpers::ControlledVocab::ExampleHelpers
  config.include_context "cv::test_unit", cv_test_unit: true
end
