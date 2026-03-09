# frozen_string_literal: true

class RelatedItemLink < ApplicationRecord
  include GenericAccessible
  include View

  belongs_to :source, class_name: "Item", inverse_of: :related_item_links
  belongs_to :target, class_name: "Item", inverse_of: :incoming_item_links
end
