# frozen_string_literal: true

module Frontend
  module Cache
    # @see Frontend::Cache::InstanceRevalidator
    class RevalidateInstance < Support::SimpleServiceOperation
      service_klass Frontend::Cache::InstanceRevalidator
    end
  end
end
