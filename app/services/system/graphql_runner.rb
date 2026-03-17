# frozen_string_literal: true

module System
  # @see System::RunGraphQL
  class GraphQLRunner < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      param :query, Types::Query

      option :current_user, ::Users::Types::Current, default: proc { AnonymousUser.new }

      option :operation_name, Types::String.optional, optional: true

      option :validate, Types::Bool, default: proc { false }

      option :variables, Types::GraphQLVariables, default: proc { {} }

      option :visibility_profile, Types::VisibilityProfile, default: proc { :public }
    end

    standard_execution!

    # @return [MutationOperations::AuthContext]
    attr_reader :auth_context

    # @return [Hash]
    attr_reader :context

    # @return [Support::Requests::State]
    attr_reader :request_state

    # @return [Hash]
    attr_reader :result

    # @return [Dry::Monads::Success(Hash)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield execute_query!
      end

      Success result
    end

    wrapped_hook! def prepare
      @auth_context = MutationOperations::AuthContext.new(current_user:)

      @request_state = Support::Requests::State.new

      @context = {
        auth_context:,
        current_user:,
        request_state:,
        visibility_profile: :public
      }

      super
    end

    wrapped_hook! def execute_query
      @result = APISchema.execute(query, variables:, context:, operation_name:, validate:)

      super
    end

    around_execute_query :wrap_request!

    private

    # @return [void]
    def wrap_request!
      request_state.wrap do
        yield
      end
    end
  end
end
