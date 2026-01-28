# frozen_string_literal: true

module System
  # @see System::Checker
  class Check < Support::SimpleServiceOperation
    service_klass System::Checker
  end
end
