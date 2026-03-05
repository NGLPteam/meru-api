# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    prepend ActionPolicy::GraphQL::AuthorizedField

    argument_class Types::BaseArgument
  end
end
