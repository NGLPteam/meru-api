# frozen_string_literal: true

# A concern for policies that don't apply any restrictions on the scope to non-admin users.
module PubliclyScopedPolicy
  extend ActiveSupport::Concern

  def resolve_scope_for_non_admin(relation)
    relation.all
  end
end
