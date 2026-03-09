# frozen_string_literal: true

module Audits
  # A view for auditing potential invalid hierarchical parents
  # for collections that have had their ancestors reparented
  # and have invalid community associations.
  class MismatchedCollectionParent < ApplicationRecord
    include GenericInaccessible
    include View

    self.primary_key = :collection_id

    belongs_to_readonly :collection
    belongs_to_readonly :invalid_community, class_name: "Community"
    belongs_to_readonly :valid_community, class_name: "Community"
  end
end
