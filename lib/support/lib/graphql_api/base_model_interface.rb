# frozen_string_literal: true

module Support
  module GraphQLAPI
    module BaseModelInterface
      extend ActiveSupport::Concern

      included do
        implements ::Support::GQL::CommonModelType

        global_id_field :id
      end

      module ClassMethods
        # @param [ApplicationRecord] object
        # @param [GraphQL::Query::Context] graphql_context
        # @raise [ActionPolicy::NotFound] if a policy cannot be found for the object
        def authorized?(object, graphql_context)
          context = { user: graphql_context[:current_user], }

          if graphql_context[:current_object].kind_of?(::Types::MutationType)
            # This is an object being loaded as an argument in a mutation.
            # If we can't even read it, throw an exception that GQL will catch and skip the mutation entirely.
            return authorize!(object, to: :read_for_mutation?, context:)
          end

          allowed_to?(:show?, object, context:)
        end

        def inherited(subclass)
          super

          subclass.global_id_field :id
        end
      end
    end
  end
end
