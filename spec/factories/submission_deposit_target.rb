# frozen_string_literal: true

FactoryBot.define do
  factory :submission_deposit_target do
    association :submission_target

    entity { submission_target.entity }
  end
end
