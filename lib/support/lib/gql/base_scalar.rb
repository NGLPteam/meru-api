# frozen_string_literal: true

module Support
  module GQL
    # @abstract
    class BaseScalar < ::GraphQL::Schema::Scalar
      extend Dry::Core::ClassAttributes

      # @api private
      module DryScalar
        extend ActiveSupport::Concern

        included do
          defines :dry_type, type: ::Support::Types::DryType
        end

        module ClassMethods
          # @param [Object] input_value
          # @raise [GraphQL::ExecutionError] If an invalid input value is provided, return a top-level GQL execution error.
          # @return [Object]
          def coerce_input(input_value, _)
            dry_type[input_value]
          rescue Dry::Types::ConstraintError => e
            raise GraphQL::ExecutionError, "Invalid Scalar Input: #{e.message}"
          end

          # @param [Object] ruby_value
          # @raise [Dry::Types::ConstraintError] we should raise this at runtime
          #   because we should never be sending invalid values through the API.
          # @return [Object]
          def coerce_result(ruby_value, _)
            dry_type[ruby_value]
          end
        end
      end

      class << self
        # Set up a scalar to wrap around a dry-type for validation.
        #
        # @param [Dry::Types::Type] type
        # @return [void]
        def wraps_dry_type!(type)
          include DryScalar

          dry_type type
        end
      end
    end
  end
end
