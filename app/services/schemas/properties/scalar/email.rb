# frozen_string_literal: true

module Schemas
  module Properties
    module Scalar
      class Email < Base
        attribute :default, :string

        fillable!

        orderable!

        schema_type! :string

        add_schema_predicate! :format?, Support::GlobalTypes::EMAIL_PATTERN

        graphql_value_key :address
      end
    end
  end
end
