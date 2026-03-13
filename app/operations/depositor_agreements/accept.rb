# frozen_string_literal: true

module DepositorAgreements
  # @see DepositorAgreements::Accepter
  class Accept < Support::SimpleServiceOperation
    service_klass DepositorAgreements::Accepter
  end
end
