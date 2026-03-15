# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Integer < Base
        attribute :gt, :integer
        attribute :gte, :integer
        attribute :lt, :integer
        attribute :lte, :integer
        attribute :default, :integer

        orderable!

        searchable!

        schema_type! :integer

        graphql_value_key :integer_value

        def build_schema_predicates
          super.merge(
            gteq?: gte,
            gt?: gt,
            lt?: lt,
            lteq?: lte
          ).compact
        end
      end
    end
  end
end
