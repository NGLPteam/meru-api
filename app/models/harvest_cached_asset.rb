# frozen_string_literal: true

# One of the slowest parts of harvesting is fetching cached assets. Often, these
# URLs are unique and don't change often, and it causes reharvesting to be a much
# lengthier process than necessary. It also produces issues when asset URLs are
# unreliable or resource-limited.
#
# We separate the asset extraction to a separate step that enables an entity to
# enter into the system much faster, possibly missing its assets, as well as
# cache asset retrieval across harvesting attempts to speed up reharvesting.
class HarvestCachedAsset < ApplicationRecord
  include CachedAssetUploader::Attachment.new(:asset)
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  has_many :harvest_cached_asset_references, inverse_of: :harvest_cached_asset, dependent: :delete_all

  attribute :metadata, Harvesting::CachedAssets::Metadata.to_type, default: -> { {} }

  scope :by_url, ->(url) { where(url:) }

  validates :url, presence: true, uniqueness: true

  def has_asset?
    asset.present?
  end

  class << self
    # @param [String] url
    # @see Harvesting::CachedAssets::Fetch
    # @yield [cached] Build a cached asset within an advisory block.
    # @yieldparam [HarvestCachedAsset] cached
    # @yieldreturn [Object]
    # @return [Object]
    def for_url(url)
      transaction do
        with_advisory_lock!(url, timeout_seconds: 60, transaction: true, disable_query_cache: true) do
          cached = HarvestCachedAsset.by_url(url).first_or_initialize

          yield cached if block_given?
        end
      end
    end
  end
end
