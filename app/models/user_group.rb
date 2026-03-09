# frozen_string_literal: true

# Not presently exposed
#
# @api private
class UserGroup < ApplicationRecord
  include AccessGrantSubject
  include GenericInaccessible
  include HasSystemSlug
  include TimestampScopes

  has_many :user_group_memberships, dependent: :destroy, inverse_of: :user_group

  has_many :users, through: :user_group_memberships

  validates :name, presence: true
end
