# frozen_string_literal: true

module MutationOperations
  # @api private
  class UserError < ::Support::FlexibleStruct
    attribute :message, ::Support::GlobalTypes::String
    attribute :code, ::Support::GlobalTypes::Coercible::String.optional
    attribute :path, ::Support::DryMutations::Types::AttributePath
    attribute :attribute_path, ::Support::GlobalTypes::String
    attribute :global, ::Support::GlobalTypes::Bool

    # The default type for errors if a code was not provided
    SERVER = "$server"

    def global?
      global.present?
    end

    # @return [(String, String)]
    def attribute_error_key
      [attribute_path, type]
    end

    def scope
      global? ? "global" : "attribute"
    end

    def to_global_error
      {
        message:,
        type:,
      }
    end

    # @return [String]
    def type
      code.presence || SERVER
    end
  end
end
