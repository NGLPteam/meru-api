# frozen_string_literal: true

module Frontend
  module Cache
    # @see Frontend::Cache::RevalidateInstance
    # @see Frontend::Cache::InstanceRevalidator
    class RevalidateInstanceJob < ApplicationJob
      queue_as :default

      # @return [void]
      def perform
        call_operation!("frontend.cache.revalidate_instance")
      end
    end
  end
end
