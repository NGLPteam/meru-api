# frozen_string_literal: true

# The base controller for all requests.
#
# @abstract
class ApplicationController < ActionController::API
  include OperationHelpers

  before_action :attach_request_id!

  # @return [void]
  def attach_request_id!
    Support::Requests::Current.request_id = request.request_id
  end

  # {#perform_operation Perform} the {Users::Authenticate authenticate operation}
  # for the current request.
  #
  # @request_action
  # @subsystem Authentication
  # @return [void]
  def authenticate_user!
    perform_operation "users.authenticate", request.env do |m|
      m.success do |user|
        Support::Requests::Current.current_user = user

        @current_user = user
      end

      m.failure(:expired) do
        render_server_message! "tokens.expired", status: :unauthorized
      end

      m.failure do |code, *errors|
        render_server_message! "tokens.invalid", status: :forbidden
      end
    end
  end

  # Render a standard, localized server error using {#render_single_error!}.
  #
  # @api private
  # @param [#to_s] key an i18n key in the `server_messages` namespace.
  # @param [{ Symbol => Object }] options (@see #render_single_error!)
  # @return [void]
  def render_server_message!(key, **options)
    render_single_error! I18n.t(key, scope: "server_messages"), **options
  end

  # Render a single, top-level error message in the format favored by GraphQL clients.
  #
  # @api private
  # @param [Symbol, Integer] status the HTTP status code (or equivalent symbol, see `Rack::Utils::SYMBOL_TO_STATUS_CODE`)
  # @param [{ Symbol => Object }] props properties to add to the error message
  # @return [void]
  def render_single_error!(message, status: :internal_server_error, **props)
    render json: { errors: [{ **props, message: } ] }, status:
  end
end
