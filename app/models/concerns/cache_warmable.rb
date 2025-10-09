# frozen_string_literal: true

# A concern for models that should warm URLs on the frontend
# via {CacheWarmer}.
module CacheWarmable
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  included do
    pg_enum! :cache_warming_status, as: :cache_warming_status, default: "default", allow_blank: false, prefix: :cache_warming

    has_one :cache_warmer, as: :warmable, dependent: :destroy, inverse_of: :warmable

    scope :cache_warming_enabled, -> { where(cache_warming_enabled: true) }

    scope :cache_warming_disabled, -> { where(cache_warming_enabled: false) }

    before_validation :determine_cache_warming_default_enabled!
    before_validation :determine_cache_warming_enabled!

    after_save :maybe_create_cache_warmer!
  end

  # @api private
  # @return [Boolean]
  def determine_cache_warmability!
    determine_cache_warming_default_enabled!
    determine_cache_warming_enabled!

    update_columns(
      cache_warming_default_enabled: cache_warming_default_enabled,
      cache_warming_enabled: cache_warming_enabled
    ) if changed?

    maybe_create_cache_warmer!
  end

  # @return [CacheWarmer]
  def maybe_create_cache_warmer!
    return unless cache_warming_enabled?

    cache_warmer || create_cache_warmer!
  end

  # @see CacheWarmers::RunWarmable
  # @return [Dry::Monads::Result]
  monadic_operation! def run_cache_warmer
    call_operation("cache_warmers.run_warmable", self)
  end

  private

  # @return [Boolean]
  def derive_cache_warming_default_enabled
    case self
    when ::Community then true
    when ::Collection then depth < CachingConfig.collection_depth
    when ::Item then depth < CachingConfig.item_depth
    else
      # :nocov:
      false
      # :nocov:
    end
  end

  # @return [Boolean]
  def derive_cache_warming_enabled
    case cache_warming_status
    when "on"
      true
    when "off"
      false
    else
      cache_warming_default_enabled
    end
  end

  # @return [void]
  def determine_cache_warming_default_enabled!
    self.cache_warming_default_enabled = derive_cache_warming_default_enabled
  end

  # @return [void]
  def determine_cache_warming_enabled!
    self.cache_warming_enabled = derive_cache_warming_enabled
  end
end
