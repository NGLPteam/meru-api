# frozen_string_literal: true

module Types
  class OrganizationContributorType < Types::AbstractModel
    implements Types::ContributorType

    description <<~TEXT
    An organization that has made contributions.
    TEXT
  end
end
