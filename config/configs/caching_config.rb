# frozen_string_literal: true

class CachingConfig < ApplicationConfig
  attr_config harvest_assets: true, warming_enabled: true, collection_depth: 2, item_depth: 0

  coerce_types harvest_assets: :boolean, warming_enabled: :boolean, collection_depth: :integer, item_depth: :integer
end
