# frozen_string_literal: true

module Support
  module Inspectable
    extend ActiveSupport::Concern

    # @return [String]
    def internal_inspect = Support::Inspector.inspect(self, skip_internal_inspect: true)
  end
end
