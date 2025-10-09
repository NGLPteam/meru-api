# frozen_string_literal: true

class CacheWarming < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :cache_warmer, inverse_of: :cache_warmings

  validates :url, presence: true
end
