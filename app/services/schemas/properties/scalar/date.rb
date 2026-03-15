# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Date < Base
        orderable!

        searchable!

        schema_type! :date

        graphql_value_key :date
      end
    end
  end
end
