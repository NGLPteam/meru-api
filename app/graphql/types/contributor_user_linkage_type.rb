# frozen_string_literal: true

module Types
  # @see ContributorUserLink
  class ContributorUserLinkageType < Types::BaseEnum
    description <<~TEXT
    The type of link between a `Contributor` and a `User` in a `ContributorUserLink`.
    TEXT

    value "PRIMARY", value: "primary" do
      description <<~TEXT
      A primary link indicates that the `Contributor` is the primary identity for the user.

      A user may only have one primary link. Setting a new primary link will invalidate the previous.
      TEXT
    end

    value "AUXILIARY", value: "auxiliary" do
      description <<~TEXT
      An auxiliary link indicates that the `Contributor` is an additional identity for the user.

      This may be the case for users who've published under different names, or are being managed
      by a user account representing a team or organization, etc.

      A user may have multiple auxiliary links. Setting a new auxiliary link does not affect existing ones.
      TEXT
    end
  end
end
