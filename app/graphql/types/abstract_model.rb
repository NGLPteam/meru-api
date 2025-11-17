# frozen_string_literal: true

module Types
  # @abstract
  class AbstractModel < Types::BaseObject
    implements GraphQL::Types::Relay::Node
    implements ::Types::SluggableType

    global_id_field :id

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    class << self
      # @param [ApplicationRecord] object
      # @param [GraphQL::Query::Context] context
      def authorized?(object, context)
        if context[:current_object].kind_of?(::Types::MutationType)
          # This is an object being loaded as an argument in a mutation.
          # If we can't even read it, throw an exception that GQL will catch and skip the mutation entirely.
          return pundit_authorize!(object, :read_for_mutation?, context)
        end

        pundit_authorized? object, :show?, context
      rescue Pundit::NotDefinedError => e
        # :nocov:
        # In development or test, we want an error raised. In production
        # environments, fall back to the old behavior of just implicitly
        # allowing access in order to ensure we're not breaking anything
        # that doesn't have a policy yet.
        raise e if Rails.env.local?

        return true
        # :nocov:
      end

      def inherited(subclass)
        super if defined?(super)

        subclass.global_id_field :id
      end
    end
  end
end
