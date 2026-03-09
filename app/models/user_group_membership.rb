# frozen_string_literal: true

# Not presently exposed
#
# @api private
class UserGroupMembership < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  belongs_to :user
  belongs_to :user_group
end
