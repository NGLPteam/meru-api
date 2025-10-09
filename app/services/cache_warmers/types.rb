# frozen_string_literal: true

module CacheWarmers
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    CacheWarmer = ModelInstance("CacheWarmer")
  end
end
