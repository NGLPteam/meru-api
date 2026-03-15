# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      # @see FullText::Types
      # @see SchematicText
      class FullText < Base
        always_wide!

        searchable!

        schema_type! :full_text

        graphql_value_key :full_text

        # @see Schemas::Properties::Context#full_text
        def extract_raw_value_from(context)
          context.full_text(full_path)
        end

        def write_values_within!(context)
          context.write_full_text! path
        end
      end
    end
  end
end
