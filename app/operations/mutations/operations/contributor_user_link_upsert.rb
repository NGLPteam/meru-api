# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ContributorUserLinkUpsert
    class ContributorUserLinkUpsert
      include MutationOperations::Base

      use_contract! :contributor_user_link_upsert

      authorizes! :contributor, with: :update?

      # @param [Contributor] contributor
      # @param [User] user
      # @param ["primary", "auxiliary"] linkage
      # @return [void]
      def call(contributor:, user:, linkage:, **)
        link = ContributorUserLink.where(contributor:).first_or_initialize

        assign_attributes!(link, user:, linkage:)

        persist_model! link, attach_to: :contributor_user_link

        attach! :contributor, contributor.reload
        attach! :user, user.reload
      end
    end
  end
end
