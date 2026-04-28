# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::ContributorUserLinkUpsert
    # @see Mutations::Operations::ContributorUserLinkUpsert
    class ContributorUserLinkUpsert < MutationOperations::Contract
      json do
        required(:contributor).value(:contributor)
        required(:user).value(:user)
        required(:linkage).value(:contributor_user_linkage)
      end
    end
  end
end
