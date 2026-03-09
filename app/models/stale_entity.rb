# frozen_string_literal: true

# A view based on {LayoutInvalidation}, with its primary key
# set to the associated {LayoutInvalidation}'s `sequence_id`.
#
# Because the `sequence_id` _decrements_ when new layout invalidations
# are created, when serially rendering this in the background, we never
# need to worry about records being replaced since they will be deterministically
# added "before" the cursor.
#
# @see Rendering::ProcessStaleEntitiesJob
class StaleEntity < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  self.primary_key = :id

  belongs_to_readonly :entity, polymorphic: true

  scope :stale_before, ->(time) { where(arel_table[:stale_at].lteq(time)) if time.present? }

  # @return [Dry::Monads::Result]
  monadic_operation! def process
    call_operation("stale_entities.process", self)
  end

  class << self
    # @param [ActiveSupport::TimeWithZone, String] before
    # @return [ActiveRecord::Relation<StaleEntity>]
    def stale(before: Time.current)
      unscoped.preload(:entity).stale_before(before)
    end
  end
end
