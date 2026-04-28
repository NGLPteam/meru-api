# frozen_string_literal: true

class DownloadsController < ApplicationController
  def show
    asset = subject = Asset.find_graphql_slug params[:id]

    entity = asset.attachable

    perform_operation "assets.decode_download_token", asset, params[:token] do |m|
      m.success do |mode|
        ahoy.track("asset.#{mode}", subject:, entity:)

        redirect_to asset.actual_download_url, status: :see_other, allow_other_host: true
      end

      m.failure :missing_token do
        render plain: "Unauthorized", status: :unauthorized
      end

      m.failure do |*ex|
        render plain: "Bad Request", status: :bad_request
      end
    end
  rescue ActiveRecord::RecordNotFound, Dry::Monads::UnwrapError
    render plain: "Not Found", status: :not_found
  end
end
