# frozen_string_literal: true

module CacheWarmers
  # @see CacheWarmers::Runner
  class Run < Support::SimpleServiceOperation
    service_klass CacheWarmers::Runner
  end
end
