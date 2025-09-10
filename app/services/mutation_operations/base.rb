# frozen_string_literal: true

module MutationOperations
  # The basic logic for an operation that backs a {Mutations::BaseMutation mutation}.
  #
  # Any given mutation operation gets set up by {MutationOperations::Middleware} and
  # goes through several lifecycle methods:
  #
  # 1. `prepare` This step is for modifying the args and preparing the local context
  #   for later steps.
  # 2. `edges` This step loads and validates any "edges" for mutations that affect
  #   the connection between two entities and factors heavily into validations.
  #   {MutationOperations::Edges#load_and_validate_edges! It uses specialized logic}.
  # 3. `validation` The final major step before execution, this validates the args
  #   provided to the mutation along with any derived edges or context.
  # 4. `contracts` A sub-step of validations, this is where
  #   {MutationOperations::Contracts#check_contracts! contracts are run} against the
  #   provided arguments. Failed contracts will add to the errors, which will prevent
  #   the final step from running at all.
  # 5. `execution` This is where the actual {#call logic of the mutation} is performed,
  #   assuming all validations and contracts passed and no other errors were set.
  #
  # All of these steps are defined as ActiveModel callbacks, so mutations can opt to
  # define hooks `after_edges`, `before_contracts`, `around_execution`, etc.
  module Base
    extend ActiveSupport::Concern

    include Support::GraphQLAPI::PunditHelpers
    include MutationOperations::AttributeExtraction
    include MutationOperations::Contracts
    include MutationOperations::Edges

    included do
      extend ActiveModel::Callbacks

      include AfterCommitEverywhere
      include Dry::Effects.CurrentTime
      include Dry::Effects::Handler.State(:args)
      include Dry::Effects::Handler.State(:execution_args)
      include Dry::Effects.Resolve(:current_user)
      include Dry::Effects.Resolve(:graphql_context)
      include Dry::Effects.Resolve(:local_context)
      include Dry::Effects.Resolve(:edges)
      include Dry::Effects.Resolve(:attribute_names)
      include Dry::Effects.Resolve(:error_compiler)
      include Dry::Effects.Resolve(:provided_args)
      include Dry::Effects.Resolve(:transient_arguments)
      include Dry::Effects.State(:args)
      include Dry::Effects.State(:execution_args)
      include Dry::Effects.State(:graphql_response)
      include Dry::Effects.Interrupt(:throw_invalid)
      include Dry::Effects.Interrupt(:throw_unauthorized)
      include Dry::Monads[:result, :validated, :list]

      define_model_callbacks :mutation, :prepare, :authorization, :edges, :contracts, :validation, :execution

      around_mutation :set_up_args!
      around_mutation :set_up_execution_args!
    end

    # @abstract The main logic of the mutation must be implemented in this method.
    # @param [{ Symbol => Object }] args
    # @return [void] The return value is not acknowledged (except for monadic failures), as it
    #   is expected that values to be returned from the API are assigned to the
    #   response with {#attach!}.
    def call(**args)
      # :nocov:
      raise NotImplementedError, "Must implement #{self.class}#call"
      # :nocov:
    end

    # @api private
    # @return [void]
    def perform_mutation!
      run_callbacks :prepare do
        prepare!
      end

      run_callbacks :authorization do
        authorize!
      end

      run_callbacks :edges do
        load_and_validate_edges!
      end

      run_callbacks :validation do
        run_callbacks :contracts do
          check_contracts!
        end

        validate!
      end

      halt_if_errors!

      unset_transient_arguments!

      run_callbacks :execution do
        call(**execution_args)
      end
    end

    # @see #perform_mutation!
    # @return [void]
    def perform!
      run_callbacks :mutation do
        perform_mutation!
      end
    end

    # Attach a `value` on `key` of the GraphQL response.
    #
    # @see #attach_many!
    # @param [Symbol] key
    # @param [Object] value
    # @return [void]
    def attach!(key, value)
      graphql_response[key] = value
    end

    # @see #attach!
    # @param [{ Symbol => Object }] pairs
    # @return [void]
    def attach_many!(**pairs)
      pairs.each do |key, value|
        attach! key, value
      end
    end

    # @param [String] message
    # @param [String] code
    # @param [String, String[]] path
    # @param [Hash] extensions
    # @return [void]
    def add_error!(message, code: nil, path: nil, force_attribute: false)
      error = error_compiler.call(message, code:, path:, force_attribute:)

      graphql_response[:errors] << error

      if error.global?
        graphql_response[:global_errors] << error.to_global_error
      else
        graphql_response[:attribute_errors].then do |errors|
          key = error.attribute_error_key

          errors[key] ||= []

          errors[key] << error.message
        end
      end
    end

    # @param [String] message
    # @return [void]
    def add_global_error!(message, type: "$global")
      error = error_compiler.global message

      graphql_response[:errors] << error

      graphql_response[:global_errors] << error.to_global_error
    end

    # @param [Symbol] code
    # @param [String] scope
    # @return [void]
    def add_global_validation_error!(code, scope: "dry_validation.errors.rules")
      message = I18n.t(code, scope:, raise: true)

      error = error_compiler.global(message, code:)

      graphql_response[:errors] << error

      graphql_response[:global_errors] << error.to_global_error
    end

    # @return [void]
    def halt_if_errors!
      throw_invalid if has_errors?
    end

    def has_errors?
      graphql_response[:errors].any? || graphql_response[:global_errors].any? || graphql_response[:attribute_errors].any?
    end

    # @abstract
    # Set the execution args as a dup of the actual args.
    # @return [void]
    def prepare!
      self.execution_args = args.dup.deep_symbolize_keys
    end

    # @abstract
    # A hook that checks for authorization to perform the mutation.
    #
    # Runs after prepare, but before validation.
    # @return [void]
    def authorize!; end

    # @abstract
    # @return [void]
    def validate!; end

    # @return [void]
    def unset_transient_arguments!
      return if transient_arguments.none?

      unset_arg_for_execution!(*transient_arguments)
    end

    # @!group Authorization logic

    def authorize(*)
      super
    rescue Pundit::NotAuthorizedError => e
      throw_unauthorized e
    end

    def pundit_user
      current_user
    end

    # @!endgroup

    # @!group model persistence

    def persist_model!(model, attach_to: nil)
      if model.save
        attach! attach_to, model if attach_to.present?

        return model
      else
        # :nocov:
        invalid_model! model
        # :nocov:
      end
    end

    def upsert_model!(klass, attributes, unique_by:, attach_to: nil)
      # :nocov:
      result = klass.upsert(attributes, returning: unique_by, unique_by:)

      conditions = unique_by.each_with_object({}) do |key, h|
        h[key.to_sym] = result.first[key.to_s]
      end

      model = klass.find_by! conditions

      attach! attach_to, model if attach_to.present?

      return model
      # :nocov:
    end

    def validate_model!(model, validation_context: nil)
      # :nocov:
      if model.valid? validation_context
        model
      else
        invalid_model! model
      end
      # :nocov:
    end

    def check_model!(model)
      # :nocov:
      return model if model.errors.none?

      invalid_model! model
      # :nocov:
    end

    def invalid_model!(model)
      # :nocov:
      add_model_errors! model

      throw_invalid
      # :nocov:
    end

    def destroy_model!(model, auth: false)
      graphql_response[:destroyed] = false

      authorize model, :destroy? if auth

      id = model.to_encoded_id

      if model.destroy
        graphql_response[:destroyed] = true

        graphql_response[:destroyed_id] = id
      else
        # :nocov:
        invalid_model! model
        # :nocov:
      end
    end

    # @param [#errors] model
    # @return [void]
    def add_model_errors!(model)
      # :nocov:
      model.errors.each do |error|
        options = {}.tap do |h|
          h[:code] = error.type.to_s if error.type.kind_of?(Symbol)
          h[:path] = [error.attribute] unless error.attribute == :base
        end

        add_error! error.message, **options
      end
      # :nocov:
    end

    # @!endgroup

    # @!group Utility methods

    # @param [String] name the fully-qualified name of the operation
    # @param [<Object>] args the arguments for the operation (if any)
    # @return [Dry::Monads::Result] This is not guaranteed, but assumed for most operations
    #   that would be called by a mutation
    def call_operation(name, *args, **kwargs)
      MeruAPI::Container[name].call(*args, **kwargs)
    end

    # @param [<Symbol>] keys
    # @return [void]
    def unset_arg_for_execution!(*keys)
      keys.flatten.each do |key|
        execution_args.delete key
      end
    end

    # Call an operation by name and run through {#with_result!} in order
    # to easily handle its result.
    #
    # @note This differs from {#with_operation_result!} in that we inline the operation
    #   call and also allow the implementation to use its own resolution logic.
    # @param [String] name the fully-qualified name of the operation
    # @param [<Object>] args the arguments for the operation (if any)
    # @yield [matcher] handle the result of the operation based on `success` or `failure`
    # @yieldparam [Dry::Matcher::ResultMatcher] matcher
    # @yieldreturn [void]
    # @return [void]
    def with_called_operation!(name, *args, **kwargs, &)
      result = call_operation(name, *args, **kwargs)

      with_result!(result, &)
    end

    # @param [Dry::Monads::Result] result
    # @yield [matcher] instance of `Dry::Result::ResultMatcher`
    # @return [Object]
    def with_result!(result, &)
      Dry::Matcher::ResultMatcher.call(result, &)
    end

    # @see #something_went_wrong!
    # @param [Dry::Monads::Result] result
    # @param [String] error_message
    # @return [Object] if the result was successful, whatever was in the success monad will be returned
    def check_result!(result, error_message: I18n.t("server_messages.errors.something_went_wrong"))
      with_result!(result) do |m|
        m.success do |value|
          value
        end

        m.failure do
          # :nocov:
          something_went_wrong!(error_message:)
          # :nocov:
        end
      end
    end

    # Short-circuit and end the mutation execution.
    #
    # @param [String] error_message
    # @return [void]
    def something_went_wrong!(error_message: I18n.t("server_messages.errors.something_went_wrong"))
      add_global_error! error_message

      throw_invalid
    end

    def with_operation_result!(result)
      # :nocov:
      with_result!(result) do |m|
        m.success do |value|
          value
        end

        m.failure do |failure|
          if failure.kind_of?(Array) && failure.length == 2
            add_global_error! failure[1], type: failure[0].to_s
          else
            add_global_error! "Something went wrong"
          end
        end
      end
      # :nocov:
    end

    def with_attached_result!(key, result)
      with_result! result do |m|
        m.success do |model|
          attach! key, model
        end

        m.failure do |(code, reason)|
          # :nocov:
          if reason.kind_of?(ApplicationRecord)
            invalid_model! reason

            break
          end

          message = reason.kind_of?(String) ? reason : "Something went wrong"

          add_error! message, code: code.to_s.presence
          # :nocov:
        end
      end
    end

    # @!endgroup

    # @!group Mutation State

    # @api private
    # @return [void]
    def set_up_args!
      local_context[:args] = provided_args

      with_args(provided_args.dup.deep_symbolize_keys) do
        yield
      end
    end

    # @api private
    # @return [void]
    def set_up_execution_args!
      with_execution_args(nil) do
        yield
      end
    end

    # @!endgroup

    module ClassMethods
      # Declare that the mutation requires the permission described by `with`
      # on a model instance stored in {#args} with the key `arg_key`.
      #
      # This can be called multiple times if a mutation requires multiple auth checks.
      #
      # @example Require update permissions for an account
      #   authorizes! :account, with: :update?
      # @param [Symbol] arg_key
      # @param [Symbol] with the verb to authorize with
      # @return [void]
      def authorizes!(arg_key, with:)
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
