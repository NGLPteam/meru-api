# frozen_string_literal: true

FactoryBot.define do
  factory :depositor_request do
    association :submission_target
    association :user
  end
end
