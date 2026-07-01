# frozen_string_literal: true

module Introspection
  class LayoutsController < Introspection::BaseController
    def show
      layout = ::Layout.find params[:layout_kind]

      render json: layout.introspect
    end

    def validate
      perform_operation("layouts.introspection.validate", params) do |m|
        m.success do |result|
          render json: result.as_json
        end

        m.failure(:invalid_params) do |code, resp|
          render json: invalid_result(resp, code:), status: :unprocessable_content
        end

        m.failure :invalid_document do |code, reason|
          render json: invalid_because(reason, code:), status: :unprocessable_content
        end

        m.failure do |error|
          # simplecov:disable
          render plain: "Something went wrong", status: :internal_server_error
          # simplecov:enable
        end
      end
    end

    private

    def invalid_because(reason, code: :unknown)
      {
        valid: false,
        code:,
        param_errors: {
          document: [reason]
        },
        errors: [],
        templates: nil,
      }
    end

    # @param [Dry::Validation::Result] result
    def invalid_result(result, code: :unknown)
      {
        valid: false,
        code:,
        param_errors: result.errors.to_h,
        errors: [],
        templates: nil,
      }
    end
  end
end
