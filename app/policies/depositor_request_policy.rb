# frozen_string_literal: true

# @see DepositorRequest
class DepositorRequestPolicy < ApplicationPolicy
  relation_scope do |relation|
    resolve_default_scope_for(relation)
  end
end
