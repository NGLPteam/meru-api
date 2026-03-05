# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    association :submission_target
    association :user
  end
end
