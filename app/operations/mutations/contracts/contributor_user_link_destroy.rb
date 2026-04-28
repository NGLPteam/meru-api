# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::ContributorUserLinkDestroy
    # @see Mutations::Operations::ContributorUserLinkDestroy
    class ContributorUserLinkDestroy < MutationOperations::Contract
      json do
        required(:contributor_user_link).value(:contributor_user_link)
      end
    end
  end
end
