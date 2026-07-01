# frozen_string_literal: true

module Seeding
  module Import
    class AttachImageProperty
      include Dry::Monads[:result, :do]

      # @param [ApplicationRecord] model
      # @param [Symbol] property
      # @param [Seeding::Import::Structs::Asset::Any, nil] asset
      # @return [Dry::Monads::Result(void)]
      def call(model, property, asset)
        return Success() if asset.blank?

        attacher = yield attacher_for model, property

        case asset.format
        when "url"
          attacher.assign_remote_url asset.url

          Success()
        else
          # simplecov:disable
          Failure[:unsupported_asset_format, asset.format]
          # simplecov:enable
        end
      end

      private

      def attacher_for(model, property)
        attacher_name = :"#{property}_attacher"

        attacher = model.public_send attacher_name

        Success attacher
      end
    end
  end
end
