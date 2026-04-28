# frozen_string_literal: true

# A connection between a {Contributor} and a {User}, indicating that the user is
# represented within Meru as that record.
class ContributorUserLink < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :linkage, as: :contributor_user_linkage, suffix: :linkage

  belongs_to :contributor, inverse_of: :contributor_user_link

  belongs_to :user, inverse_of: :contributor_user_links

  scope :in_default_order, -> { order(linkage: :asc).joins(:contributor).merge(Contributor.in_default_order) }

  before_save :enforce_primary_uniqueness!, if: :primary_linkage?

  private

  # @return [void]
  def enforce_primary_uniqueness!
    self.class.where(user_id:).primary_linkage.where.not(contributor_id:).update_all(linkage: "auxiliary")
  end
end
