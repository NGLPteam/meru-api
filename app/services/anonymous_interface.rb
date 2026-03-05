# frozen_string_literal: true

# Project-specific methods for {AnonymousUser}.
#
# @see Support::Users::AnonymousInterface
module AnonymousInterface
  extend ActiveSupport::Concern

  def access_management = "forbidden"

  # @see User#assignable_roles
  # @return [ActiveRecord::Relation<Role>]
  def assignable_roles = Role.none

  def can_manage_access_contextually? = false

  def can_manage_access_globally? = false

  def forbidden_access_management? = true
end
