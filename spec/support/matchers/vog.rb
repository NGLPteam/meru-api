# frozen_string_literal: true

RSpec::Matchers.define :be_a_vog_filtering_input_object do
  match do |actual|
    actual.kind_of?(Class) && actual < ::Support::GQL::BaseFilterScopeInputObject
  end

  description do
    "be a VOG filtering input object"
  end

  failure_message do |actual|
    "expected that `#{actual.inspect}` would be a VOG filtering input object"
  end
end
