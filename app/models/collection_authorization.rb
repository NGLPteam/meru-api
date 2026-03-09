# frozen_string_literal: true

class CollectionAuthorization < ApplicationRecord
  include GenericInaccessible
  include MaterializedView

  self.primary_key = :collection_id

  belongs_to :collection
  belongs_to :community
end
