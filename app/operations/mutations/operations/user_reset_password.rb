# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::UserResetPassword
    class UserResetPassword
      include MutationOperations::Base

      use_contract! :user_reset_password

      authorizes! :user, with: :reset_password?

      # @param [User] user
      # @param [String] client_id
      # @param [String] location
      # @param [String] redirect_path
      # @return [void]
      def call(user:, client_id:, location:, redirect_path:)
        user.update_password_via_email(client_id:, location:, redirect_path:) do |m|
          m.success do
            attach! :user, user
            attach! :success, true
          end

          m.failure :request_failed do |_, error_message|
            something_went_wrong!(error_message:)
          end

          m.failure do
            # simplecov:disable
            something_went_wrong!
            # simplecov:enable
          end
        end
      end

      private

      # @return [void]
      before_prepare def derive_user!
        args[:user] ||= current_user
      end
    end
  end
end
