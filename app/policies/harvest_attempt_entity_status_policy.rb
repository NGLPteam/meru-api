# frozen_string_literal: true

# @see HarvestAttemptEntityStatus
class HarvestAttemptEntityStatusPolicy < AbstractHarvestPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
