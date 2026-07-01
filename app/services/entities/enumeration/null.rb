# frozen_string_literal: true

module Entities
  module Enumeration
    # Enumerate no relations (acts as a default) when not otherwise specified.
    class Null < Abstract
      def build_hierarchical_scope
        # simplecov:disable
        super.none
        # simplecov:enable
      end
    end
  end
end
