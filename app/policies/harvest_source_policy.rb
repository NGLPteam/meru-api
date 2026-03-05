# frozen_string_literal: true

# @see HarvestSource
class HarvestSourcePolicy < AbstractHarvestPolicy
  def create? = has_admin?
end
