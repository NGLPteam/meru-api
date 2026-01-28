# frozen_string_literal: true

module Entities
  # Populate and maintain the {EntityHierarchy} table from descendants.
  #
  # This happens automatically when {Entities::Sync} is called.
  #
  # @see Entities::HierarchyPopulator
  class SyncHierarchies < Support::SimpleServiceOperation
    service_klass Entities::HierarchyPopulator
  end
end
