# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::EntityListCacher
    class CacheEntityList < Support::SimpleServiceOperation
      service_klass Templates::Instances::EntityListCacher
    end
  end
end
