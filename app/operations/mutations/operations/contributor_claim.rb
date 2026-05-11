# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ContributorClaim
    class ContributorClaim
      include MutationOperations::Base

      use_contract! :contributor_claim

      authorizes! :contributor, with: :claim?
      authorizes! :current_user, with: :claim_contributor?

      # @param [Contributor] contributor
      # @return [void]
      def call(contributor:, **)
        with_attached_result! :contributor_user_link, contributor.link_user(current_user, linkage: :primary)

        attach! :contributor, contributor.reload
        attach! :user, current_user.reload
      end
    end
  end
end
