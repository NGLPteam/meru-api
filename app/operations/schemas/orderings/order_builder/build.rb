# frozen_string_literal: true

module Schemas
  module Orderings
    module OrderBuilder
      class Build
        extend Dry::Core::Cache

        # @param [String] path
        # @return [Schemas::Orderings::OrderBuilder::Base]
        def call(path)
          fetch_or_store path do
            case path
            when Schemas::Orderings::OrderBuilder::ANCESTOR_STATIC_PATTERN
              Regexp.last_match => { ancestor_name:, path: }

              StaticAncestorOrderableProperty.find(path).order_builder_for(ancestor_name)
            when Schemas::Orderings::OrderBuilder::ANCESTOR_PROPS_PATTERN
              Regexp.last_match => { ancestor_name: }

              Schemas::Orderings::OrderBuilder::BySchemaProperty.new(ancestor_name:)
            when Schemas::Orderings::OrderBuilder::PROPS_PATTERN
              Schemas::Orderings::OrderBuilder::BySchemaProperty.new
            when Schemas::Orderings::OrderBuilder::STATIC_PATTERN
              StaticOrderableProperty.find(path).order_builder
            else
              # simplecov:disable
              raise "Cannot derive order builder for #{path}"
              # simplecov:enable
            end
          end
        end
      end
    end
  end
end
