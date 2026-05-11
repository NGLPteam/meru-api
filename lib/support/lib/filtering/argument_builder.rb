# frozen_string_literal: true

module Support
  module Filtering
    # Used within {Support::Filtering::Arguments#add!} to build argument types with a DSL.
    #
    # @api private
    class ArgumentBuilder
      include Dry::Initializer[undefined: false].define -> do
        param :type, Support::DryGQL::Types::Type

        option :required, Support::DryGQL::Types::Bool.default(false), optional: true, as: :provided_required
      end

      # @return [Support::DryGQL::Types::Type]
      def call
        @current_type = type

        required! if provided_required

        yield self if block_given?

        return @current_type
      end

      # @param [Object] value
      # @param [Boolean] replace_null whether to replace null values with the default value when the argument is not provided in the GraphQL query.
      # @return [void]
      def default(value, replace_null: false)
        augment_type do |t|
          augment_type do |t|
            t.gql_default(value, replace_null)
          end
        end
      end

      # Set the GraphQL description for this argument.
      # @param [String] text
      # @return [void]
      def description(text)
        augment_type do |t|
          t.gql_description text
        end
      end

      # Mark the argument as required.
      # @return [void]
      def required!
        augment_type do |t|
          t.gql_required true
        end
      end

      private

      # Iteratively build the dry type by yielding to the block one or more times.
      # @yieldreturn [Dry::Types::Type, nil] the block can return a new type to update the current type, or nil to keep the current type.
      # @return [void]
      def augment_type
        new_type = yield @current_type

        @current_type = Support::DryGQL::Types::Type[new_type] if new_type.present?

        return
      end
    end
  end
end
