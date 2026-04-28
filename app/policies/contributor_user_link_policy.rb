# frozen_string_literal: true

# @see ContributorUserLink
class ContributorUserLinkPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  pre_check :allow_any_admin!
end
