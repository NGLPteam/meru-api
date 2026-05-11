# frozen_string_literal: true

module Support
  module Filtering
    # A runner class that applies filtering scopes to ActiveRecord relations.
    #
    # @see Support::Filtering::Run
    # @note Primarily used in testing. Use `Support::System["filtering.run"]` to execute.
    class Runner
      include Dry::Monads[:result]
      include Dry::Initializer[undefined: false].define -> do
        param :klass, Support::Models::Types::ModelClass

        option :base_scope, Types::Scope, default: proc { klass.all }
        option :options, Types::FilterOptions
        option :filter_klass, ::Support::Filtering::AbstractScope::Subclass, default: proc { "::Support::Filtering::Scopes::#{klass.model_name.to_s.pluralize}".constantize }
        option :current_user, ::Support::Users::Types::Current, default: ::Support::Users::Types::DEFAULT_FROM_REQUEST
      end

      # @return [Support::Filtering::FilterScope]
      attr_reader :filters

      # @return [ActiveRecord::Relation]
      def call
        @filters = filter_klass.new(**options, current_user:)

        result = filters.apply_to base_scope

        Success result
      end
    end
  end
end
