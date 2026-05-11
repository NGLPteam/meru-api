# frozen_string_literal: true

module Roles
  # @see Roles::SystemCalculator
  class CalculateSystem < Support::SimpleServiceOperation
    service_klass Roles::SystemCalculator
  end
end
