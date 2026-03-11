# frozen_string_literal: true

module Protocols
  module Types
    extend ::Support::Typespace

    CurrentPage = Coercible::Integer.constrained(gt: 0).default(1).fallback(1)

    PageCount = Coercible::Integer.constrained(gteq: 0).default(0).fallback(0)

    RecordCount = Coercible::Integer.constrained(gteq: 0).default(0).fallback(0)

    URL = String.constrained(http_uri: true)
  end
end
