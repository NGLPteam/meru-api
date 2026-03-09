# frozen_string_literal: true

module Audits
  # A view for auditing potential invalid hierarchical parents
  # for items that have had their ancestors reparented
  # and have invalid collection associations.
  class MismatchedItemParent < ApplicationRecord
    include GenericInaccessible
    include View

    self.primary_key = :item_id

    belongs_to_readonly :item
    belongs_to_readonly :invalid_collection, class_name: "Collection"
    belongs_to_readonly :valid_collection, class_name: "Collection"
  end
end
