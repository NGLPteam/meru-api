# frozen_string_literal: true

module Sources
  class SchemaPropertyContext < GraphQL::Dataloader::Source
    include MeruAPI::Deps[to_context: "schemas.instances.read_property_context"]

    # @param [<HasSchemaDefinition>] records
    def fetch(records)
      records.map { |record| to_context(record) }
    end

    private

    def to_context(record)
      MeruAPI::Container["schemas.instances.read_property_context"].(record)
    end
  end
end
