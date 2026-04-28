# frozen_string_literal: true

module Mutations
  module Operations
    # @see Mutations::ContributorUserLinkDestroy
    class ContributorUserLinkDestroy
      include MutationOperations::Base

      use_contract! :contributor_user_link_destroy

      authorizes! :contributor_user_link, with: :destroy?

      # @param [ContributorUserLink] contributor_user_link
      # @return [void]
      def call(contributor_user_link:)
        destroy_model! contributor_user_link, auth: true
      end
    end
  end
end
