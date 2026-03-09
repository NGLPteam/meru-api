# frozen_string_literal: true

# A simple record that marks an {Ordering} as stale and in need of being refreshed.
#
# @see OrderingInvalidations::ProcessAllJob
# @see OrderingInvalidations::Process
# @see OrderingInvalidations::Processor
class OrderingInvalidation < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :ordering, inverse_of: :ordering_invalidations

  scope :in_default_order, -> { reorder(ordering_id: :asc, stale_at: :desc) }
  scope :for_ordering, -> { distinct_on(:ordering_id).includes(:ordering) }
  scope :stale_before, ->(time) { where(arel_table[:stale_at].lteq(time)) if time.present? }

  # @see OrderingInvalidations::Process
  # @see OrderingInvalidations::Processor
  monadic_operation! def process
    call_operation("ordering_invalidations.process", self)
  end

  class << self
    # It's possible an ordering might be enqueued multiple times. Given such
    # a situation, we use `DISTINCT ON` to grab only one ordering per batch,
    # and clear out all previous / duplicate batches as long as they have
    # a `stale_at` timestamp below our retrieved record.
    #
    # @param [ActiveSupport::TimeWithZone, String] before
    # @return [ActiveRecord::Relation<OrderingInvalidation>]
    def stale(before: Time.current)
      base = unscoped.for_ordering.in_default_order.stale_before(before).select(:id)

      where(id: base)
    end
  end
end
