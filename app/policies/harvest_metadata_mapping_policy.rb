# frozen_string_literal: true

# @see HarvestMetadataMapping
class HarvestMetadataMappingPolicy < AbstractHarvestPolicy
  def create? = has_admin?
end
