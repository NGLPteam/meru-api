# frozen_string_literal: true

# @see Permalink
# @see Types::PermalinkableType
module Permalinkable
  extend ActiveSupport::Concern

  included do
    has_many :permalinks, -> { in_default_order }, as: :permalinkable, dependent: :destroy, inverse_of: :permalinkable

    has_one_readonly :canonical_permalink, -> { canonical }, as: :permalinkable, class_name: "Permalink"
  end
end
