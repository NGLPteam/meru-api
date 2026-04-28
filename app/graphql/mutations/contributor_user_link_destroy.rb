# frozen_string_literal: true

module Mutations
  # @see Mutations::Operations::ContributorUserLinkDestroy
  class ContributorUserLinkDestroy < Mutations::BaseMutation
    description <<~TEXT
    Destroy a single `ContributorUserLink` record.
    TEXT

    argument :contributor_user_link_id, ID, loads: Types::ContributorUserLinkType, required: true do
      description <<~TEXT
      The contributor user link to destroy.
      TEXT
    end

    performs_operation! "mutations.operations.contributor_user_link_destroy", destroy: true
  end
end
