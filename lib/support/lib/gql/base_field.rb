# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseField < ::GraphQL::Schema::Field
      prepend ::ActionPolicy::GraphQL::AuthorizedField

      argument_class ::Support::GQL::BaseArgument
    end
  end
end
