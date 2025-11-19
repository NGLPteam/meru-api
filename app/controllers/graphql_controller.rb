# frozen_string_literal: true

# Request handling for the GraphQL API.
class GraphQLController < ApplicationController
  before_action :authenticate_user!

  # This method handles all GraphQL requests that Meru-API receives.
  #
  # @see APISchema
  # @return [void]
  def execute
    variables = prepare_variables(params[:variables])

    query = params[:query]

    operation_name = params[:operationName]

    request_state = Support::Requests::State.new

    request_state.set_up_timer!(
      query:,
      operation_name:,
      variables:,
    )

    context = {
      ahoy:,
      current_user: @current_user,
      request_state:,
    }

    json = request_state.wrap do
      APISchema.execute(query, variables:, context:, operation_name:, validate: MeruConfig.validate_graphql_query?)
    end

    render(json:)
  rescue StandardError => e
    # :nocov:
    raise e unless Rails.env.development?

    handle_error_in_development e
    # :nocov:
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  #
  # @param [String, Hash, ActionController::Parameters] variables_param
  # @return [Hash]
  def prepare_variables(variables_param)
    # :nocov:
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
    # :nocov:
  end

  # Render a backtrace for errors that occur in development.
  #
  # @param [Exception] err
  # @return [void]
  def handle_error_in_development(err)
    # :nocov:
    logger.error err.message
    logger.error err.backtrace.join("\n")

    render json: { errors: [{ message: err.message, backtrace: err.backtrace }], data: {} }, status: :internal_server_error
    # :nocov:
  end
end
