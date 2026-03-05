# frozen_string_literal: true

# @see Entity
class EntityPolicy < EntityChildRecordPolicy
  private

  def show_full_scope? = has_allowed_action?("admin.access")

  def resolve_scope_for_authenticated(relation)
    if show_full_scope?
      relation.all
    else
      relation.currently_visible
    end
  end

  def resolve_scope_for_anonymous(relation)
    relation.currently_visible
  end
end
