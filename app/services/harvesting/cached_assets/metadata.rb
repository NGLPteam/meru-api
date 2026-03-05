# frozen_string_literal: true

module Harvesting
  module CachedAssets
    class Metadata
      include ::Support::EnhancedStoreModel

      attribute :not_found, :boolean, default: false
    end
  end
end
