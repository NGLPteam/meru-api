# frozen_string_literal: true

module Support
  module Filtering
    class Run < Support::SimpleServiceOperation
      service_klass Support::Filtering::Runner
    end
  end
end
