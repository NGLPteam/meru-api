# frozen_string_literal: true

module Schemas
  module Texts
    # @see Schemas::Texts::Writer
    class Write < Support::SimpleServiceOperation
      service_klass Schemas::Texts::Writer
    end
  end
end
