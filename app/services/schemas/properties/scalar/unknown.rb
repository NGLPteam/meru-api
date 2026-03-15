# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      # A fallback type that will catch possible discrepancies. Shouldn't occur normally.
      class Unknown < Base
        attribute :default, :any_json

        schema_type! :any

        graphql_value_key :unknown_value
      end
    end
  end
end
