# frozen_string_literal: true

module Types
  # @abstract
  class BaseField < ::Support::GQL::BaseField
    argument_class ::Types::BaseArgument
  end
end
