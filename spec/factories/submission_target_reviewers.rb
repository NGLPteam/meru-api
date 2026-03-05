# frozen_string_literal: true

FactoryBot.define do
  factory :submission_target_reviewer do
    association :submission_target
    association :user
  end
end
