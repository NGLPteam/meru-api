# frozen_string_literal: true

# A calculated view that determines available candidates to link a source {Entity} to.
class LinkTargetCandidate < ApplicationRecord
  include GenericAccessible
  include TimestampScopes
  include View

  self.primary_key = %i[source_type source_id target_type target_id].freeze

  belongs_to :source, polymorphic: true
  belongs_to :target, polymorphic: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  scope :collections, -> { where(target_type: "Collection") }
  scope :items, -> { where(target_type: "Item") }

  class << self
    def matching_title(needle)
      return all if needle.blank? || !/\S{3,}/.match?(needle)

      quoted_needle = needle.gsub(?%, "%%").gsub(?*, ?%).to_s

      quoted_needle = "%#{quoted_needle}" unless quoted_needle.match?(/\A%(?!%)/)
      quoted_needle += ?% unless quoted_needle.match?(/(?<!%)%\z/)

      where(arel_table[:title].matches(quoted_needle))
    end
  end
end
