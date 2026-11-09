# frozen_string_literal: true

module FrozenSchema
  extend ActiveSupport::Concern

  included do
    extend Dry::Core::ClassAttributes

    defines :schema, type: Dry::Types::Nominal.new(Dry::Schema::Processor)
    defines :has_merged_schemas, type: Dry::Types["bool"]
    defines :merged_schemas, type: ::Support::GlobalTypes::Array.of(Support::GlobalTypes.Instance(Dry::Schema::Processor))

    has_merged_schemas false

    merged_schemas []
  end

  class_methods do
    # @note We repurpose this built-in method to apply our schema
    def assign_defaults!(record)
      return super if schema.blank?

      result = schema.call record

      if has_merged_schemas
        handle_merged_schemas(result, record:)
      else
        handle_single_schema result
      end
    end

    def default_attributes
      schema.present? ? {} : nil
    end

    def schema!(*parent_schemas, &)
      defined = Dry::Schema.Params(&)

      handled_schemas = parent_schemas.map do |parent|
        MeruAPI::Container["utility.schemafy"].(parent)
      end

      has_merged_schemas handled_schemas.size > 0

      merged = [*handled_schemas, defined].reduce(&:&)

      merged_schemas [*handled_schemas, defined]

      schema merged
    end

    private

    # @param [#failure?] result
    # @return [Hash]
    def handle_merged_schemas(result, record:)
      if result.failure?
        merged_schemas.each do |schema|
          result = schema.(record)

          # rubocop:disable-next Rails/Output
          puts result.errors.inspect if result.failure?
        end

        raise "Problem with merged schemas (better errors TBI)"
      end

      merged_schemas.reduce({}) do |merged, schema|
        merged.reverse_merge(schema.(record).to_h.stringify_keys)
      end
    end

    # @param [Dry::Schema::Result] result
    # @return [Hash]
    def handle_single_schema(result)
      return result.to_monad.value! if result.failure?

      result.to_h.deep_stringify_keys
    end
  end
end
