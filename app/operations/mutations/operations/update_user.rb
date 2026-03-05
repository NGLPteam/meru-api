# frozen_string_literal: true

module Mutations
  module Operations
    class UpdateUser
      include MutationOperations::Base

      include MeruAPI::Deps[
        update_profile: "users.update_profile"
      ]

      attachment! :avatar, image: true

      authorizes! :user, with: :update?

      def call(user:, profile: {}, **args)
        updated = update_profile.call user, **profile

        user = with_operation_result! updated

        assign_attributes! user, **args

        persist_model! user, attach_to: :user
      end
    end
  end
end
