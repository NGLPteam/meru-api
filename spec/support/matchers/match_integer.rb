# frozen_string_literal: true

RSpec::Matchers.define :match_integer do |expected|
  match do |actual|
    case expected
    when Range
      expected.cover?(actual)
    else
      actual == expected
    end
  end
end
