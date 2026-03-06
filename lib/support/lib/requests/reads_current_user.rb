# frozen_string_literal: true

module Support
  module Requests
    # Read the current user from the request context.
    module ReadsCurrentUser
      extend ActiveSupport::Concern

      # @return [AnonymousUser, User]
      def current_user
        Support::Requests::Current.current_user
      end
    end
  end
end
