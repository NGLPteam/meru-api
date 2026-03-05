# frozen_string_literal: true

# In practice, transitions are always visible to authenticated users. The only
# way to access them is through a parent record, and the parent record's policy
# will determine whether the user can see the transition or not.
#
# @abstract
class AbstractTransitionPolicy < ApplicationPolicy
  always_readable!

  def create? = false

  def update? = false

  def destroy? = false

  def resolve_scope_for_authenticated(relation)
    relation.all
  end

  def resolve_scope_for_anonymous(relation)
    # :nocov:
    relation.none
    # :nocov:
  end
end
