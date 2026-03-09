# frozen_string_literal: true

# A generic policy for records that should not ever be accessed through
# the API. This is just a catch-all for making sure that we have a policy
# for every model, even if it remains unavailable within the API.
#
# @see GenericInaccessible
class GenericInaccessiblePolicy < ApplicationPolicy
  pre_check :deny_all_access!

  relation_scope do |relation|
    # :nocov:
    relation.none
    # :nocov:
  end

  private

  # @return [void]
  def deny_all_access! = deny!
end
