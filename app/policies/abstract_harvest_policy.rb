# frozen_string_literal: true

# @abstract
class AbstractHarvestPolicy < ApplicationPolicy
  readable_in_dev!

  def prune_entities? = has_admin?
end
