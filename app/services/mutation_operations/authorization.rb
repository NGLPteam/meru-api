# frozen_string_literal: true

module MutationOperations
  # Authorization logic for {MutationOperations::Base} mutations.
  module Authorization
    extend ActiveSupport::Concern

    # @return [MutationOperations::AuthContext]
    def auth_context
      graphql_context[:auth_context] || AuthContext.new(current_user:)
    end

    delegate :authorize!, :policy_for, :allowed_to?, to: :auth_context

    # @see https://actionpolicy.evilmartians.io/#/behaviour
    # @return [void]
    def authorize(record, to, **options)
      authorize!(record, **options, to:)
    rescue ActionPolicy::Unauthorized
      throw_unauthorized
    end

    module ClassMethods
      # Declare that the mutation requires the permission described by `with`
      # on a model instance stored in {#args} with the key `arg_key`.
      #
      # This can be called multiple times if a mutation requires multiple auth checks.
      # All must pass for the mutation to be authorized.
      #
      # @see https://actionpolicy.evilmartians.io/#/
      # @example Require update permissions for an account
      #   authorizes! :account, with: :update?
      # @param [Symbol] arg_key the name of the argument holding the record to authorize
      # @param [Symbol] with the verb to authorize with, must end with a `"?"` (@see MutationOperations::Types::AuthPredicate)
      # @return [void]
      def authorizes!(arg_key, with:, each: false)
        key = MutationOperations::Types::ArgKey[arg_key]

        predicate = MutationOperations::Types::AuthPredicate[with]

        verb = predicate.to_s.chomp(??)

        if arg_key == :current_user
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            before_authorization def authorize_current_user_to_#{verb}!
              authorize current_user, #{predicate.inspect}
            end
          RUBY
          return
        elsif each
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          before_authorization def authorize_each_in_#{arg_key}_to_#{verb}!
            models = Array(args.fetch(#{key.inspect}))

            models.each do |model|
              authorize model, #{predicate.inspect}
            end
          end
          RUBY

          return
        end

        class_eval <<~RUBY, __FILE__, __LINE__ + 1
        before_authorization def authorize_#{arg_key}_to_#{verb}!
          model = args.fetch(#{key.inspect})

          authorize model, #{predicate.inspect}
        end
        RUBY
      end
    end
  end
end
