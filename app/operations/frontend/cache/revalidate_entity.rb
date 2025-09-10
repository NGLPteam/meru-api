# frozen_string_literal: true

module Frontend
  module Cache
    # @see Frontend::Cache::EntityRevalidator
    class RevalidateEntity < Support::SimpleServiceOperation
      service_klass Frontend::Cache::EntityRevalidator
    end
  end
end
