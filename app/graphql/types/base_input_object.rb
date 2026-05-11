# frozen_string_literal: true

module Types
  # @abstract
  class BaseInputObject < ::Support::GQL::BaseInputObject
    argument_class ::Types::BaseArgument
  end
end
