# frozen_string_literal: true

# Add ability to add GraphQL Metadata
Dry::Types.define_builder :gql_type do |type, arg|
  if arg.nil?
    type.meta[:gql_type] || ::Support::System["dry_gql.find_gql_type"].(type)
  else
    type.meta(
      gql_type: ::Support::System["dry_gql.find_gql_type"].(arg)
    ).set_gql_typing
  end
end

Dry::Types.define_builder :gql_loads do |type, arg|
  type.meta(
    gql_type: ::Support::System["dry_gql.find_gql_type"].(:id),
    gql_loads: arg
  ).set_gql_typing
end

Dry::Types.define_builder :gql_description do |type, arg|
  type.meta(
    gql_description: arg
  ).set_gql_typing
end

Dry::Types.define_builder :gql_required do |type, arg|
  type.meta(
    gql_required: Dry::Types["params.bool"].(arg)
  ).set_gql_typing
end

module Support
  module GQLTypingExtension
    def has_gql_typing?
      meta[:gql_typing].present?
    end

    def gql_typing
      meta.fetch(:gql_typing) do
        if respond_to?(:primitive) && primitive == ::Array
          member.gql_typing.as_array
        else
          derive_gql_typing
        end
      end
    end

    # @api private
    def derive_gql_typing
      actual_type = gql_type
      array = primitive?([])
      loads = meta[:gql_loads]
      description = meta[:gql_description]
      required = meta[:gql_required]

      Support::DryGQL::Typing.new(
        actual_type:,
        loads:,
        array:,
        description:,
        required:
      )
    end

    # @api private
    def set_gql_typing
      meta(gql_typing: derive_gql_typing)
    end
  end
end

Dry::Types::Type.include Support::GQLTypingExtension
