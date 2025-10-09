# frozen_string_literal: true

# @see CacheWarmable
class CacheWarmer < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :warmable, polymorphic: true

  has_many :cache_warmings, dependent: :delete_all, inverse_of: :cache_warmer

  # @see CacheWarmers::Run
  # @see CacheWarmers::Runner
  monadic_operation! def run
    call_operation("cache_warmers.run", self)
  end

  # @see CacheWarmers::EnqueueEnabledJob
  # @see CacheWarmers::RunJob
  # @return [void]
  def run_asynchronously!
    CacheWarmers::RunJob.perform_later self
  end

  class << self
    # @return [ActiveRecord::Relation<CacheWarmer>]
    def enabled(global: CachingConfig.warming_enabled?)
      return none unless global

      where(arel_enabled_by_warmable)
    end

    # @api private
    # @return [Arel::Nodes::Case]
    def arel_enabled_by_warmable
      comm_query = Community.cache_warming_enabled.select(:id)
      coll_query = Collection.cache_warming_enabled.select(:id)
      item_query = Item.cache_warming_enabled.select(:id)

      arel_case(arel_table[:warmable_type]) do |c|
        c.when("Community").then(arel_attr_in_query(:warmable_id, comm_query.to_sql))
        c.when("Collection").then(arel_attr_in_query(:warmable_id, coll_query.to_sql))
        c.when("Item").then(arel_attr_in_query(:warmable_id, item_query.to_sql))
        c.else(true)
      end
    end
  end
end
