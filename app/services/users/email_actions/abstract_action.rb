# frozen_string_literal: true

module Users
  module EmailActions
    # @abstract
    # @see KeycloakAPI::EmailActionsExecutor
    # @see KeycloakAPI::ExecuteActionsEmail
    class AbstractAction < Support::HookBased::Actor
      extend Dry::Core::ClassAttributes

      include Dry::Core::Constants

      include Dry::Initializer[undefined: false].define -> do
        param :user, ::Users::Types::Authenticated

        option :client_id, ::Meru::Types::KeycloakClientID

        option :location, ::Meru::Types::ClientLocation

        option :redirect_path, ::KeycloakAPI::Types::RedirectPath
      end

      defines :actions, type: ::KeycloakAPI::Types::EmailActions

      actions EMPTY_ARRAY

      standard_execution!

      include MeruAPI::Deps[
        execute_email: "keycloak_api.execute_actions_email"
      ]

      delegate :keycloak_id, to: :user

      alias user_id keycloak_id

      # @return [String]
      attr_reader :client_url

      # @return [String]
      attr_reader :redirect_uri

      # @return [Dry::Monads::Result]
      def call
        run_callbacks :execute do
          yield prepare!

          yield execute_email_action!
        end

        Success()
      end

      wrapped_hook! def prepare
        @client_url = location_to_client_url

        @redirect_uri = URI.join(client_url, redirect_path).to_s

        super
      end

      wrapped_hook! def execute_email_action
        yield execute_email.(user_id, actions, client_id:, redirect_uri:)

        super
      end

      private

      # @return [<String>]
      def actions
        self.class.actions
      end

      def location_to_client_url
        case location
        in "admin"
          LocationsConfig.admin
        in "frontend"
          LocationsConfig.frontend
        else
          # simplecov:disable
          raise "Unknown location: #{location}"
          # simplecov:enable
        end
      end
    end
  end
end
