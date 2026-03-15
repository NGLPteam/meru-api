# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      # A schema property that represents a variable-precision date object.
      #
      # @see VariablePrecisionDate
      class VariableDate < Base
        schema_type! :variable_date

        orderable!

        searchable!

        graphql_value_key :date_with_precision

        def normalize_schema_value_before_coercer(raw:, **)
          validate_raw_value raw
        end

        def validate_raw_value(extracted_value)
          VariablePrecisionDate.parse extracted_value
        end
      end
    end
  end
end
