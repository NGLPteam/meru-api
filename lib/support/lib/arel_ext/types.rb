# frozen_string_literal: true

module Support
  module ArelExt
    module Types
      extend ::Support::Typespace

      ManyArray = Array.of(Any).constrained(min_size: 2)

      NullsDir = Coercible::String.fallback("last").enum("last", "first").constructor do |raw|
        value = raw.to_s.downcase

        case value
        when "asc" then "last"
        when "desc" then "first"
        else
          value
        end
      end

      SortDir = Coercible::String.fallback("asc").enum("asc", "desc").constructor do |value|
        value.to_s.downcase
      end

      ToSQL = Interface(:to_sql)
    end
  end
end
