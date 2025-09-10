# frozen_string_literal: true

module Mutations
  module Shared
    # Shared functionality for revalidating the frontend cache.
    module RevalidatesFrontendCache
      extend ActiveSupport::Concern

      included do
        extend Dry::Core::ClassAttributes

        defines :revalidation_operation, type: Support::GlobalTypes::String
      end

      private

      def revalidate_frontend_cache!(*args, **kwargs)
        with_called_operation!(self.class.revalidation_operation, *args, **kwargs, manual: true) do |m|
          m.success do
            attach! :revalidated, true
          end

          m.failure(:timeout) do
            add_global_validation_error!(:revalidation_timeout)
          end

          m.failure(:invalid_secret) do
            add_global_validation_error!(:revalidation_secret_invalid)
          end

          m.failure do
            add_global_validation_error!(:revalidation_request_failed)
          end
        end

        halt_if_errors!
      end
    end
  end
end
