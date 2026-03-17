# frozen_string_literal: true

module Schemas
  module Instances
    class Reindex
      include Dry::Monads[:result, :do]
      include MeruAPI::Deps[
        extract_searchable_properties: "schemas.instances.extract_searchable_properties",
        extract_composed_text: "schemas.instances.extract_composed_text",
      ]

      # @param [HierarchicalEntity] entity
      def call(entity)
        yield entity.write_schematic_texts

        yield extract_searchable_properties.(entity)

        yield extract_composed_text.(entity)

        Success()
      end
    end
  end
end
