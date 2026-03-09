# frozen_string_literal: true

# A join model that connects an {AccessGrant} with a {User} that can manage it.
class AccessGrantManagementLink < ApplicationRecord
  include GenericInaccessible
  include ScopesForUser
  include View

  belongs_to :access_grant
  belongs_to :user
end
