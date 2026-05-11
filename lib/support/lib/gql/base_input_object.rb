# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseInputObject < ::GraphQL::Schema::InputObject
      argument_class ::Support::GQL::BaseArgument

      class << self
        # @param [String, Symbol] name
        # @return [Boolean] whether this input object has an argument with the given name
        def has_argument_named?(name) = arguments.key?(name.to_s)
      end
    end
  end
end
