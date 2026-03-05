# frozen_string_literal: true

# @see ContributionRoleConfiguration
class ContributionRoleConfigurationPolicy < ApplicationPolicy
  always_readable!

  def upsert? = has_admin?

  alias_rule :create?, :update?, to: :upsert?
end
