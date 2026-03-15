# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Timestamp < Base
        orderable!

        searchable!

        schema_type! :time

        graphql_value_key :timestamp
      end
    end
  end
end
