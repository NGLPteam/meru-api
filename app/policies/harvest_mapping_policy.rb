# frozen_string_literal: true

# @see HarvestMapping
class HarvestMappingPolicy < AbstractHarvestPolicy
  def create? =has_admin?
end
