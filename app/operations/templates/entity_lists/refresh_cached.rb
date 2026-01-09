# frozen_string_literal: true

module Templates
  module EntityLists
    # @see Templates::EntityLists::CachedRefresher
    class RefreshCached < Support::SimpleServiceOperation
      service_klass Templates::EntityLists::CachedRefresher
    end
  end
end
