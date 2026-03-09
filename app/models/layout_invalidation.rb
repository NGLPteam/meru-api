# frozen_string_literal: true

# A record that marks an entity in need of re-rendering its layouts.
#
# @see Rendering::ProcessLayoutInvalidationsJob
class LayoutInvalidation < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :entity, polymorphic: true, inverse_of: :layout_invalidations, optional: true

  scope :in_default_order, -> { reorder(entity_id: :asc, stale_at: :desc) }
  scope :for_entity, -> { distinct_on(:entity_id).includes(:entity) }
  scope :stale_before, ->(time) { where(arel_table[:stale_at].lteq(time)) if time.present? }

  # @see LayoutInvalidations::Process
  # @see LayoutInvalidations::Processor
  monadic_operation! def process
    call_operation("layout_invalidations.process", self)
  end

  class << self
    # It's possible an entity might be enqueued multiple times. Given such
    # a situation, we use `DISTINCT ON` to grab only one entity per batch,
    # and clear out all previous / duplicate batches as long as they have
    # a `stale_at` timestamp below our retrieved record.
    #
    # @param [ActiveSupport::TimeWithZone, String] before
    # @return [ActiveRecord::Relation<LayoutInvalidation>]
    def stale(before: Time.current)
      base = unscoped.for_entity.in_default_order.stale_before(before).select(:id)

      where(id: base)
    end
  end
end
