# frozen_string_literal: true

module Access
  # @see Access::PolymorphicGranter
  class PolymorphicGrant < Support::SimpleServiceOperation
    service_klass Access::PolymorphicGranter
  end
end
