# frozen_string_literal: true

class RelatedCollectionLink < ApplicationRecord
  include GenericAccessible
  include View

  belongs_to :source, class_name: "Collection", inverse_of: :related_collection_links
  belongs_to :target, class_name: "Collection", inverse_of: :incoming_collection_links
end
