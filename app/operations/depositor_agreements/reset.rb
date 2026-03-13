# frozen_string_literal: true

module DepositorAgreements
  # @see DepositorAgreements::Resetter
  class Reset < Support::SimpleServiceOperation
    service_klass DepositorAgreements::Resetter
  end
end
