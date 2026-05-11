# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ContributorUserLinkUpsert
    class ContributorUserLinkUpsert
      include MutationOperations::Base

      use_contract! :contributor_user_link_upsert

      authorizes! :contributor, with: :link_user?

      # @param [Contributor] contributor
      # @param [User] user
      # @param ["primary", "auxiliary"] linkage
      # @return [void]
      def call(contributor:, user:, linkage:, **)
        with_attached_result! :contributor_user_link, contributor.link_user(user, linkage:)

        attach! :contributor, contributor.reload
        attach! :user, user.reload
      end
    end
  end
end
