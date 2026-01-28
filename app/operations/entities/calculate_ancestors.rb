# frozen_string_literal: true

module Entities
  # Calculate {EntityAncestor}s for a given descendant entity.
  #
  # @see Entities::AncestorCalculator
  class CalculateAncestors < Support::SimpleServiceOperation
    service_klass Entities::AncestorCalculator
  end
end
