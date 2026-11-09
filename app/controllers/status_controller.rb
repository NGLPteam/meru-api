# frozen_string_literal: true

# Endpoints for reporting on the status and health of the API.
class StatusController < ApplicationController
  DECLARATION = Rails.application.version_declaration.freeze

  # A ping endpoint.
  #
  # @return [void]
  def ping
    render json: { pong: true }
  end

  # The root endpoint.
  #
  # @return [void]
  def root
    render plain: DECLARATION
  end
end
