# frozen_string_literal: true

module Support
  module Requests
    # Request helper types
    module Types
      extend ::Support::Typespace

      Count = Integer.constrained(gteq: 0).default(0).fallback(0)

      Path = Array.of(String)
    end
  end
end
