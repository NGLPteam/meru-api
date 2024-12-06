# frozen_string_literal: true

module Types
  class PersonContributorType < Types::AbstractModel
    implements Types::ContributorType

    description <<~TEXT
    A person that has made contributions.
    TEXT
  end
end
